# MySQL InnoDB Cluster for Kubernetes

> Oracle MySQL Operator를 사용한 고가용성 MySQL 클러스터 구성

## 아키텍처

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         MySQL InnoDB Cluster                                  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐     │
│  │                    MySQL Router (2 replicas)                        │     │
│  │  ┌──────────────────────┐    ┌──────────────────────┐               │     │
│  │  │   :6446 (R/W)        │    │   :6447 (R/O)        │               │     │
│  │  │   → Primary          │    │   → Secondary LB     │               │     │
│  │  └──────────────────────┘    └──────────────────────┘               │     │
│  └─────────────────────────────────────────────────────────────────────┘     │
│                          │                    │                              │
│                          ▼                    ▼                              │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │                  Group Replication (3 instances)                      │   │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                │   │
│  │  │ mysql-0     │    │ mysql-1     │    │ mysql-2     │                │   │
│  │  │ PRIMARY     │◀──▶│ SECONDARY   │◀──▶│ SECONDARY   │                │   │
│  │  │ (k8s-n1)    │    │ (k8s-n2)    │    │ (k8s-n3)    │                │   │
│  │  └─────────────┘    └─────────────┘    └─────────────┘                │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## 설치 순서

| 순서 | 파일 | 설명 |
|------|------|------|
| 1 | `01-mysql-operator.yaml` | MySQL Operator 설치 (Helm 또는 kubectl) |
| 2 | `02-mysql-secret.yaml` | Root 비밀번호 Secret |
| 3 | `03-local-storage.yaml` | Local StorageClass + PV (각 노드별) |
| 4 | `04-innodb-cluster.yaml` | InnoDB Cluster 생성 (3 instances + 2 routers) |
| 5 | `05-app-user.yaml` | DB/User/Schema 초기화 Job |
| 6 | `06-mysql-backup.yaml` | 자동 백업 CronJob (매일 02:00) |
| 7 | `07-backend-deployment.yaml` | FastAPI 백엔드 (MySQL Cluster 연동) |

## 배포

```bash
# Step 1: MySQL Operator 설치
helm repo add mysql-operator https://mysql.github.io/mysql-operator/
helm repo update
helm install mysql-operator mysql-operator/mysql-operator \
  --namespace mysql-operator --create-namespace

# Step 2~7: 순서대로 적용
kubectl apply -f 02-mysql-secret.yaml
kubectl apply -f 03-local-storage.yaml
kubectl apply -f 04-innodb-cluster.yaml

# InnoDB Cluster Ready 대기 (약 3~5분)
kubectl get innodbcluster -n gition -w

# App User 생성 (클러스터 Ready 후)
kubectl apply -f 05-app-user.yaml

# 백업 CronJob
kubectl apply -f 06-mysql-backup.yaml

# 백엔드 배포
kubectl apply -f 07-backend-deployment.yaml
```

## 연결 정보

| 포트 | 용도 | 대상 |
|------|------|------|
| **6446** | Read/Write | Primary만 연결 |
| **6447** | Read-Only | Secondary 로드밸런싱 |
| **6448** | X Protocol R/W | MySQL X Protocol |
| **6449** | X Protocol R/O | MySQL X Protocol |

## 클러스터 상태 확인

```bash
# InnoDB Cluster 상태
kubectl get innodbcluster -n gition

# Pod 상태
kubectl get pods -n gition -l mysql.oracle.com/cluster=mysql-cluster

# MySQL 접속
kubectl exec -it mysql-cluster-0 -n gition -c mysql -- mysqlsh --uri root@localhost

# MySQL Shell에서
\sql
SELECT member_host, member_state, member_role FROM performance_schema.replication_group_members;
```

## Failover 시나리오

Primary 노드 장애 시:
1. Group Replication이 자동으로 새 Primary 선출 (약 5~10초)
2. MySQL Router가 자동으로 새 Primary로 :6446 라우팅
3. 애플리케이션은 재연결만 필요 (자동 처리)

```bash
# Failover 테스트
kubectl delete pod mysql-cluster-0 -n gition

# 새 Primary 확인
kubectl get pods -n gition -l mysql.oracle.com/cluster=mysql-cluster
```

## 백업 및 복구

```bash
# 수동 백업 실행
kubectl create job --from=cronjob/mysql-backup manual-backup -n gition

# 백업 확인
kubectl exec -it $(kubectl get pod -n gition -l app=nfs-client-provisioner -o jsonpath='{.items[0].metadata.name}') -- ls -la /persistentvolumes/gition-mysql-backup-pvc-*/

# 복구
kubectl exec -it mysql-cluster-0 -n gition -c mysql -- mysql -uroot -p < backup.sql
```

## 트러블슈팅

```bash
# Operator 로그
kubectl logs -n mysql-operator deployment/mysql-operator

# MySQL Pod 로그
kubectl logs mysql-cluster-0 -n gition -c mysql

# Router 로그
kubectl logs mysql-cluster-router-0 -n gition
```
