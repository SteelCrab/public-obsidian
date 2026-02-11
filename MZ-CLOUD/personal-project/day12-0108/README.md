# 🐬 Day 12 - MySQL InnoDB Cluster 구축 가이드 (Operator 방식)

> MySQL Operator for Kubernetes를 사용한 자동화된 InnoDB Cluster 구축

---

## 📑 목차

1. [📋 개요](#-개요)
2. [🏗️ 아키텍처](#️-아키텍처)
3. [🚀 구축 가이드](#-구축-가이드)
4. [✅ 검증](#-검증)
5. [🔧 트러블슈팅](#-트러블슈팅)
6. [📁 파일 구조](#-파일-구조)
7. [📚 참고 자료](#-참고-자료)

---

## 📋 개요

**MySQL Operator for Kubernetes**를 사용하여 InnoDB Cluster를 자동으로 구축합니다.

### 왜 Operator인가?

| 구분 | StatefulSet (수동) | MySQL Operator (자동) |
|------|-------------------|----------------------|
| **클러스터 생성** | MySQL Shell 수동 | ✅ 자동 |
| **Failover** | 수동 복구 | ✅ 자동 |
| **MySQL Router** | 별도 배포 | ✅ 자동 포함 |
| **백업/복원** | 스크립트 작성 | ✅ CRD 제공 |
| **스케일링** | 수동 | ✅ replicas 변경만 |

### 상세 비교: 기존 Docker MySQL + NFS vs InnoDB Cluster + Operator

| 구분 | 기존 Docker MySQL + NFS | InnoDB Cluster + Operator |
|------|-------------------------|---------------------------|
| **MySQL 실행 방식** | 단일/수동 Replication | **클러스터 기반** |
| **Primary 선정** | 사람이 직접 지정 | **자동 선출 (쿼럼)** |
| **장애 대응** | 수동 | **자동 Failover** |
| **애플리케이션 연결** | Primary 직접 연결 | **MySQL Router 단일 엔드포인트** |
| **Primary 장애 시** | 서비스 중단 | **무중단 또는 최소 중단** |
| **데이터 복제** | binlog 비동기 | **Group Replication (동기/합의)** |
| **Split-brain 방지** | 없음 | **있음** |
| **스토리지** | **NFS (공유, SPOF)** | **Block Storage (개별 PV)** |
| **Kubernetes 친화성** | 낮음 | **매우 높음** |
| **운영 난이도** | 낮아 보이나 위험 | **초기 높음, 운영 안정** |
| **프로덕션 적합성** | ❌ | **✅** |

---

## 🏗️ 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                        │
├─────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────────┐  │
│  │              MySQL Operator (Controller)               │  │
│  │    자동: 클러스터 생성, Failover, Router 관리           │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│                            ▼                                 │
│   ┌──────────────────┐    감시/관리                          │
│   │   MySQL Router   │  ← 읽기/쓰기 라우팅                    │
│   │   (2 replicas)   │    :6446 (R/W), :6447 (R/O)          │
│   └────────┬─────────┘                                       │
│            │                                                 │
│   ┌────────┴────────┬────────────────┐                       │
│   ▼                 ▼                ▼                       │
│ ┌──────┐       ┌──────┐        ┌──────┐                      │
│ │mysql │       │mysql │        │mysql │                      │
│ │ -0   │ ←───→ │ -1   │ ←────→ │ -2   │   Group Replication  │
│ │(R/W) │       │(R/O) │        │(R/O) │                      │
│ └──────┘       └──────┘        └──────┘                      │
│                                                              │
│ ┌────────────────────────────────────────────┐              │
│ │       Persistent Volumes (각 노드별)        │              │
│ └────────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

### 포트 구성

| 포트 | 용도 |
|------|------|
| 3306 | MySQL 클라이언트 (직접 연결) |
| 6446 | MySQL Router (R/W) |
| 6447 | MySQL Router (R/O) |
| 6448 | MySQL Router (R/W X Protocol) |
| 6449 | MySQL Router (R/O X Protocol) |
| 33061 | Group Replication 통신 |

---

## 🚀 구축 가이드

### Step 0: 기존 MySQL 리소스 삭제 (마이그레이션 시)

> ⚠️ **주의**: 기존 Master-Slave 구성에서 마이그레이션하는 경우에만 수행

```bash
# 기존 리소스 삭제
kubectl delete statefulset mysql-slave -n gition
kubectl delete svc mysql-read mysql-master -n gition
kubectl delete configmap mysql-slave-config -n gition
kubectl delete pvc -l app=mysql -n gition
```

---

### Step 1: MySQL Operator 설치

####  Helm 사용 (권장)

```bash
# Helm 저장소 추가
helm repo add mysql-operator https://mysql.github.io/mysql-operator/
helm repo update

# Operator 설치
helm install mysql-operator mysql-operator/mysql-operator \
  --namespace mysql-operator \
  --create-namespace
```

#### 설치 확인

```bash
kubectl get pods -n mysql-operator
# NAME                              READY   STATUS    RESTARTS   AGE
# mysql-operator-xxxxxxxxxx-xxxxx   1/1     Running   0          1m
```

---

### Step 2: Secret 생성

```bash
# Namespace 생성
# 없을 경우
kubectl create namespace gition

# Secret 생성 (⚠️ 비밀번호 변경!)
kubectl create secret generic mysql-cluster-secret -n gition \
  --from-literal=rootUser=root \
  --from-literal=rootHost=% \
  --from-literal=rootPassword='<STRONG_PASSWORD>'
```

또는 YAML 파일 사용:
```bash
kubectl apply -f k8s/mysql-cluster/02-mysql-secret.yaml
```

---

### Step 3: Local PV 생성

각 K8s Worker 노드에서 디렉토리 생성 (k8s-m에서 실행):
```bash
for node in k8s-n1 k8s-n2 k8s-n3; do
  ssh $node "sudo mkdir -p /mnt/mysql-data && sudo chmod 777 /mnt/mysql-data"
done
```

StorageClass 및 PV 생성:
```bash
kubectl apply -f k8s/mysql-cluster/03-local-storage.yaml
```

PV 상태 확인:
```bash
kubectl get pv -l app=mysql-cluster


# NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS    VOLUMEATTRIBUTESCLASS   REASON   AGE
# mysql-pv-0   5Gi        RWO            Retain           Available           local-storage   <unset>                          3m34s
# mysql-pv-1   5Gi        RWO            Retain           Available           local-storage   <unset>                          3m34s
# mysql-pv-2   5Gi        RWO            Retain           Available           local-storage   <unset>                          3m34s
```
```

---

### Step 4: InnoDB Cluster 생성

```bash
kubectl apply -f k8s/mysql-cluster/04-innodb-cluster.yaml
```

#### 클러스터 상태 확인

```bash
# InnoDBCluster 리소스 확인
kubectl get innodbcluster -n gition

# Pod 상태 확인 (3개 MySQL + 2개 Router)
kubectl get pods -n gition -l mysql.oracle.com/cluster=mysql-cluster
# NAME              READY   STATUS     RESTARTS   AGE
# mysql-cluster-0   2/2     Running    0          3m
# mysql-cluster-1   2/2     Running    0          3m
# mysql-cluster-2   0/2     Init:0/3   0          3m

# 상세 상태
kubectl describe innodbcluster mysql-cluster -n gition
```

> ⏳ 클러스터가 완전히 준비되는 데 약 5-10분 소요

---

### Step 5: DB 스키마 초기화

클러스터가 `ONLINE` 상태가 되면:

```bash
kubectl apply -f k8s/mysql-cluster/05-app-user.yaml
```

Job 상태 확인:
```bash
kubectl get jobs -n gition
kubectl logs job/mysql-init-schema -n gition
```

---

### Step 6: 자동 백업 설정 (선택)

NFS에 매일 02:00 mysqldump 백업:

```bash
kubectl apply -f k8s/mysql-cluster/06-mysql-backup.yaml
```

CronJob 확인:
```bash
kubectl get cronjob -n gition
# NAME           SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
# mysql-backup   0 17 * * *    False     0        <none>          1m
```

---

### Step 7: Backend 배포

> ⚠️ **주의**: 기존 `fastapi-deployment.yaml` 삭제 필요

```bash
# 기존 배포 삭제
kubectl delete -f k8s/fastapi-deployment.yaml -n gition 2>/dev/null || true

# 새 Backend 배포 (MySQL Cluster 연동)
kubectl apply -f k8s/mysql-cluster/07-backend-deployment.yaml
```

Backend 상태 확인:
```bash
kubectl get pods -n gition -l app=api
kubectl logs -n gition -l app=api --tail=20
```

---

### Step 8: 애플리케이션 연결 설정

#### 연결 정보

| 용도 | 호스트 | 포트 |
|------|--------|------|
| R/W (쓰기) | `mysql-cluster` | 6446 |
| R/O (읽기) | `mysql-cluster` | 6447 |

#### FastAPI 환경변수 예시

```yaml
env:
- name: MYSQL_WRITE_HOST
  value: "mysql-cluster"
- name: MYSQL_WRITE_PORT
  value: "6446"
- name: MYSQL_READ_HOST
  value: "mysql-cluster"
- name: MYSQL_READ_PORT
  value: "6447"
```

---

## ✅ 검증

### 클러스터 상태 확인

```bash
# InnoDBCluster 상태
kubectl get innodbcluster -n gition -o wide

# 출력 예시:
# NAME            STATUS   ONLINE   INSTANCES   ROUTERS   AGE
# mysql-cluster   ONLINE   3        3           2         10m
```

### Primary 노드 확인

```bash
# Router를 통해 Primary 확인 (6446 = R/W = Primary)
kubectl exec -it mysql-cluster-0 -n gition -c mysql -- \
  mysql -h mysql-cluster -P 6446 -uroot -p -e "SELECT @@hostname"

# 모든 멤버 역할 확인
kubectl exec -it mysql-cluster-0 -n gition -c mysql -- \
  mysql -uroot -p -e "SELECT member_host, member_role FROM performance_schema.replication_group_members"

# 출력 예시:
# +-----------------------------------------------+-------------+
# | member_host                                   | member_role |
# +-----------------------------------------------+-------------+
# | mysql-cluster-0.mysql-cluster.gition.svc...   | PRIMARY     |
# | mysql-cluster-1.mysql-cluster.gition.svc...   | SECONDARY   |
# | mysql-cluster-2.mysql-cluster.gition.svc...   | SECONDARY   |
# +-----------------------------------------------+-------------+
```

### MySQL 연결 테스트

```bash
# R/W 연결 (Primary)
kubectl exec -it mysql-cluster-0 -n gition -c mysql -- \
  mysql -h mysql-cluster -P 6446 -uroot -p -e "SELECT @@hostname, @@read_only"

# R/O 연결 (Secondary)
kubectl exec -it mysql-cluster-0 -n gition -c mysql -- \
  mysql -h mysql-cluster -P 6447 -uroot -p -e "SELECT @@hostname, @@read_only"
```

### 자동 Failover 테스트

#### 1. 현재 Primary 확인

현재 어떤 노드가 Primary인지 확인합니다.

```bash
kubectl exec -it mysql-cluster-0 -n gition -c mysql -- \
  mysql -uroot -p -e "SELECT member_host, member_role FROM performance_schema.replication_group_members"
```

#### 2. Primary Pod 삭제

Primary 노드를 강제 삭제하여 장애 상황을 시뮬레이션합니다.

```bash
# Primary가 mysql-cluster-2이라고 가정
kubectl delete pod mysql-cluster-2 -n gition
```

#### 3. Failover 모니터링 (약 30초~1분)

MySQL Operator가 자동으로 새 Primary를 선출하는 과정을 실시간으로 확인합니다.

```bash
# Pod 상태 실시간 확인
kubectl get pods -n gition -l mysql.oracle.com/cluster=mysql-cluster -w

# 클러스터 상태 확인
kubectl get innodbcluster -n gition
```

#### 4. 새 Primary 확인

Failover 완료 후 새로운 Primary가 선출되었는지 확인합니다.

```bash
# mysql-cluster-1에서 확인 (0이 재시작 중이므로)
kubectl exec -it mysql-cluster-1 -n gition -c mysql -- \
  mysql -uroot -p -e "SELECT member_host, member_role FROM performance_schema.replication_group_members"
```

#### 예상 결과

**Before:**
```
mysql-cluster-0 → PRIMARY
mysql-cluster-1 → SECONDARY
mysql-cluster-2 → SECONDARY
```

**After (mysql-cluster-0 삭제 후):**
```
mysql-cluster-1 → PRIMARY     ← 자동 승격!
mysql-cluster-2 → SECONDARY
mysql-cluster-0 → (재시작 후) SECONDARY
```

> ✅ 자동 Failover 성공 시 애플리케이션은 MySQL Router를 통해 **무중단**으로 새 Primary에 연결됩니다.

---

## 🔧 트러블슈팅

### Operator가 설치되지 않음

```bash
# CRD 확인
kubectl get crd innodbclusters.mysql.oracle.com

# 없으면 재설치
kubectl apply -f https://raw.githubusercontent.com/mysql/mysql-operator/trunk/deploy/deploy-crds.yaml
```

### 클러스터가 PENDING 상태

```bash
# 이벤트 확인
kubectl describe innodbcluster mysql-cluster -n gition

# Pod 로그 확인
kubectl logs mysql-cluster-0 -n gition -c mysql
kubectl logs mysql-cluster-0 -n gition -c sidecar
```

### StorageClass 문제

```bash
# StorageClass 확인
kubectl get sc

# PVC 상태 확인
kubectl get pvc -n gition
```

### Router 연결 실패

```bash
# Router Pod 확인
kubectl get pods -n gition -l component=router

# Router 로그
kubectl logs -l component=router -n gition
```

---

## 📁 파일 구조

```
day12-0108/
├── README.md                               # 이 문서
└── k8s/
    └── mysql-cluster/
        ├── 01-mysql-operator.yaml          # [Step 1] Operator 설치 가이드
        ├── 02-mysql-secret.yaml            # [Step 2] Secret (비밀번호)
        ├── 03-local-storage.yaml           # [Step 3] Local PV StorageClass
        ├── 04-innodb-cluster.yaml          # [Step 4] InnoDBCluster CR
        ├── 05-app-user.yaml                # [Step 5] 스키마 초기화 Job
        ├── 06-mysql-backup.yaml            # [Step 6] 자동 백업 CronJob (NFS)
        └── 07-backend-deployment.yaml      # [Step 7] Backend API Deployment
```

### 배포 순서

```bash
# 1. Operator 설치 (한 번만)
helm install mysql-operator mysql-operator/mysql-operator -n mysql-operator --create-namespace

# 2. Secret
kubectl apply -f k8s/mysql-cluster/02-mysql-secret.yaml

# 3. Local PV
kubectl apply -f k8s/mysql-cluster/03-local-storage.yaml

# 4. InnoDB Cluster
kubectl apply -f k8s/mysql-cluster/04-innodb-cluster.yaml

# 5. 스키마 초기화 (클러스터 ONLINE 후)
kubectl apply -f k8s/mysql-cluster/05-app-user.yaml

# 6. 백업 CronJob (선택)
kubectl apply -f k8s/mysql-cluster/06-mysql-backup.yaml

# 7. Backend 배포 (기존 fastapi-deployment.yaml 삭제 필요)
kubectl apply -f k8s/mysql-cluster/07-backend-deployment.yaml
```

---

## 📚 참고 자료

- [MySQL Operator for Kubernetes](https://dev.mysql.com/doc/mysql-operator/en/)
- [MySQL InnoDB Cluster](https://dev.mysql.com/doc/refman/8.0/en/mysql-innodb-cluster-userguide.html)
- [GitHub: mysql/mysql-operator](https://github.com/mysql/mysql-operator)
- [MySQL Router](https://dev.mysql.com/doc/mysql-router/8.0/en/)
