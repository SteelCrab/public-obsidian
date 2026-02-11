# Day 6 - MySQL Primary 접속 설정 (01/02)

> K8s에서 외부 MySQL Primary (172.100.100.11)로 쓰기 접속 구성

## 📋 목차

1. [개요](#-개요)
2. [아키텍처](#-아키텍처)
3. [MySQL Primary 시작](#-mysql-master-시작)
4. [K8s 서비스 설정](#-k8s-서비스-설정)
5. [접속 테스트](#-접속-테스트)
6. [트러블슈팅](#-트러블슈팅)
7. [참고](#-참고)

---

## 📌 개요

### 목표

- **읽기**: K8s 내부 MySQL Slave (`mysql-read`) 사용
- **쓰기**: 외부 MySQL Primary (`mysql-master`) 사용

### 현재 구성

| 서비스 | 타입 | 대상 | 용도 |
|--------|------|------|------|
| `mysql-read` | Headless | K8s StatefulSet Pods | 읽기 (로드밸런싱) |
| `mysql-master` | ExternalName/Endpoints | 172.100.100.11 | 쓰기 |

---

## 🏗️ 아키텍처

```
                         ┌───────────────────────────────────────┐
                         │           FastAPI API                 │
                         └───────────────────┬───────────────────┘
                                             │
                    ┌────────────────────────┴────────────────────┐
                    │                                             │
                    │                                             │
           ┌───────────────┐                       ┌───────────────┐
           │ mysql-master  │                       │  mysql-read   │
           │ (Endpoints)   │                       │ (Headless)    │
           └───────┬───────┘                       └───────┬───────┘
                   │                                       │
                   │                                       │
        ┌──────────────────────┐               ┌───────────────────────────────┐
        │ 외부 MySQL           │               │   K8s StatefulSet Pods        │
        │ 172.100.100.11       │               │ ┌───────────┐ ┌───────────┐   │
        │ (Primary/Write)      │               │ │ mysql-0   │ │ mysql-1   │   │
        └──────────────────────┘               │ │ (Slave)   │ │ (Slave)   │   │
                                               │ └───────────┘ └───────────┘   │
                                               └───────────────────────────────┘
```

---

## 🗃️ MySQL Primary 시작

### 1. NFS 마운트 확인 (MySQL VM: 172.100.100.11)

```bash
# NFS 마운트 확인
df -h | grep DATA

# 마운트가 안 되어 있으면
sudo mount -t nfs 172.100.100.10:/mnt/DATA /mnt/DATA
```

### 2. Docker Compose로 MySQL 시작

```bash
cd /mnt/DATA/mysql
docker compose up -d

# 상태 확인
docker ps
```

### 3. 접속 테스트 (K8s 노드에서)

```bash
nc -zv 172.100.100.11 3306
# 성공: Connection to 172.100.100.11 3306 port [tcp/mysql] succeeded!
```

---

## ⚙️ K8s 서비스 설정

### ExternalName 방식 (기존)

```yaml
# mysql-slave.yaml에 포함
apiVersion: v1
kind: Service
metadata:
  name: mysql-master
  namespace: gition
spec:
  type: ExternalName
  externalName: "172.100.100.11"
```

> [!WARNING]
> ExternalName은 IP 주소에서 DNS 해석에 실패로 작동하지 않을 수 있습니다.

### Endpoints 방식 (권장)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-master
  namespace: gition
spec:
  ports:
  - port: 3306
    targetPort: 3306
---
apiVersion: v1
kind: Endpoints
metadata:
  name: mysql-master
  namespace: gition
subsets:
  - addresses:
      - ip: 172.100.100.11
    ports:
      - port: 3306
```

### 적용

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: mysql-master
  namespace: gition
spec:
  ports:
  - port: 3306
    targetPort: 3306
---
apiVersion: v1
kind: Endpoints
metadata:
  name: mysql-master
  namespace: gition
subsets:
  - addresses:
      - ip: 172.100.100.11
    ports:
      - port: 3306
EOF
```

---

## 🔗 접속 테스트

### 1. 엔드포인트 확인

```bash
kubectl get endpoints mysql-master -n gition
# 출력:
# NAME            ENDPOINTS             AGE
# mysql-master   172.100.100.11:3306   78s
```

### 2. DNS 테스트

```bash
kubectl run test-dns --image=busybox -n gition --rm -it --restart=Never -- nslookup mysql-master.gition.svc.cluster.local
```

| 명령어 | 설명 |
|---------|-------------|
| `kubectl run test-dns --image=busybox -n gition --rm -it --restart=Never -- nslookup mysql-master.gition.svc.cluster.local` | 임시 busybox Pod를 실행해 `mysql-master` 서비스의 FQDN을 사용한 DNS 조회를 수행합니다. |

### 실제 실행 결과

```bash
kubectl get endpoints mysql-master -n gition
# 출력:
# NAME            ENDPOINTS             AGE
# mysql-master   172.100.100.11:3306   78s

kubectl run test-dns --image=busybox -n gition --rm -it --restart=Never -- nslookup mysql-master.gition.svc.cluster.local
# 출력: (NXDOMAIN 특이 빈 결과)
```

**문제 원인**: `nslookup`은 FQDN을 사용하지 않으면 DNS 해석에 실패합니다. 항상 같이 `mysql-master.gition.svc.cluster.local` 로 조회해야 합니다.

**해결 방법**:
- 서비스 이름은 FQDN 형태로 사용합니다.
- `kubectl get svc mysql-master -n gition` 로 서비스 존재 확인.
- CoreDNS 파드가 정상 동작 중인지 `kubectl get pods -n kube-system -l k8s-app=kube-dns` 로 확인.
- 엔드포인트가 올바르게 설정되는지 `kubectl get endpoints mysql-master -n gition` 로 확인.

---
### 실제 실행 결과 (추가)

```bash
kubectl get svc mysql-master -n gition
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
mysql-master   ClusterIP   10.100.170.157   <none>        3306/TCP   4d7h

kubectl get pods -n kube-system -l k8s-app=kube-dns
NAME                       READY   STATUS    RESTARTS   AGE
coredns-668d6bf9bc-g2xm6   1/1     Running   0          22h
coredns-668d6bf9bc-zq5jm   1/1     Running   0          22h

kubectl get endpoints mysql-master -n gition
NAME            ENDPOINTS             AGE
mysql-master   172.100.100.11:3306   148m
```


### 3. Pod에서 접속 테스트

> [!NOTE]
> FastAPI 이미지(`python:3.14-slim`)에는 MySQL 클라이언트가 없으므로, 별도의 `mysql:8.0` 이미지를 사용한 임시 Pod로 테스트합니다.

```bash
kubectl run test-mysql --image=mysql:8.0 -n gition --rm -it --restart=Never -- \
  mysql -h mysql-master -u pista -p<PASSWORD> -e "SHOW DATABASES;"
```

### 4. API 로그 확인

```bash
kubectl rollout restart deployment api -n gition
sleep 15
kubectl logs -l app=api -n gition | grep -i "database\|pool"

# 출력: Database pool initialized
```

---

## ⚠️ 트러블슈팅

### 문제: MySQL 접속 거부

```
nc: connect to 172.100.100.11 port 3306 (tcp) failed: Connection refused
```

**원인**: MySQL 컨테이너가 실행 중이지 않음

**해결**:
```bash
# MySQL VM에서
cd /mnt/DATA/mysql
docker compose up -d
docker ps
```

### 문제: NFS 마운트 안됨

**원인**: `/etc/fstab`에 잘못된 설정

```bash
# 잘못된 예
nfs:/mnt/DATA /mnt/DATA nfs defaults 0 0

# 올바른 설정
172.100.100.10:/mnt/DATA /mnt/DATA nfs defaults 0 0
```

**해결**:
```bash
# 잘못된 항목 삭제 후 올바른 항목 추가
sudo sed -i '/nfs:\/mnt\/DATA/d' /etc/fstab
echo '172.100.100.10:/mnt/DATA /mnt/DATA nfs defaults 0 0' | sudo tee -a /etc/fstab
```

### 문제: ExternalName DNS 해석 실패

```
** server can't find mysql-master.gition.svc.cluster.local: NXDOMAIN
```

**원인**: ExternalName은 IP 주소에서 실패로 작동하지 않음

**해결**: Endpoints 방식으로 서비스 변경 (위 참조)

---

## 🔄 연동 테스트 (K8s ↔ MySQL Primary)

FastAPI 애플리케이션과 외부 MySQL Primary가 정상적으로 통신하는지 확인하는 절차입니다.

### 1단계: DB 접속 및 쿼리 테스트 (가장 확실한 방법)

FastAPI 파드에는 MySQL 클라이언트가 없으므로, 별도의 임시 Pod를 생성하여 테스트합니다.

```bash
# 임시 Pod 생성 및 DB 접속 테스트
kubectl run test-mysql --image=mysql:8.0 -n gition --rm -it --restart=Never -- \
  mysql -h mysql-master -u pista -p<비밀번호> -e "SHOW DATABASES;"
```

**성공 시 출력 예시**:
```text
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
```

### 2단계: 접속 실패 시 DNS 및 네트워크 확인

DB 접속에 실패한 경우, DNS 해석이나 네트워크 차단 여부를 확인합니다.

```bash
# 임시 busybox Pod 실행
kubectl run test-net --image=busybox -n gition --rm -it --restart=Never -- sh

# 1. DNS 확인
nslookup mysql-master.gition.svc.cluster.local
# -> Address: 172.100.100.11 확인

# 2. 포트 접속 확인
nc -zv 172.100.100.11 3306
# -> Connected to 172.100.100.11
```

### 3단계: FastAPI 로그 확인

재 배포 후 로그에서 DB 접속 오류가 없는지 확인합니다.

```bash
kubectl logs -l app=api -n gition --tail=50 | grep -i "database\|pool\|error"
```

### 4단계: 문제 발생 시 체크리스트

| 체크 항목 | 확인 방법 |
|----------|-----------|
| Service 존재 여부 | `kubectl get svc mysql-master -n gition` |
| Endpoints 확인 | `kubectl get endpoints mysql-master -n gition` |
| CoreDNS 정상 | `kubectl get pods -n kube-system -l k8s-app=kube-dns` |
| 네트워크 정책 | `kubectl get networkpolicy -n gition` |
| MySQL 방화벽 | VM에서 `iptables -L` 또는 보안그룹 확인 |


## 📚 참고

- [Day 1 - 인프라 구축](../day1-1224/install-3tier/README.md)
- [Day 2 - 애플리케이션 배포](../day2-1229/README.md)
- [Day 3 - 외부 GitLab Registry 연동](../day3-1230/README.md)
- [Day 4 - GitLab CI/CD 및 Containerd 설정](../day4-1231/README.md)
- [Day 5 - Health Check 및 MySQL DNS 설정](../day5-0101/README.md)

---
