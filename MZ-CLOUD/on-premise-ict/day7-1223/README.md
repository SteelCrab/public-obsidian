# 📅 Day 7: DB Replication (Master-Slave)

Kubernetes 환경에서 MySQL Master-Slave 복제 구조 구성

---

## 📑 목차

1. [🗄️ 개요](#️-개요)
2. [🏗️ 구성](#️-구성)
3. [🚀 빠른 시작](#-빠른-시작)
   - [사전 준비](#0️⃣-사전-준비-pre-requisites)
   - [Master 설정](#1️⃣-master-설정-vm---docker-compose)
   - [Slave 배포](#2️⃣-slave-배포-kubernetes---statefulset)
   - [복제 확인](#3️⃣-복제-확인)
4. [🔧 트러블슈팅](#-트러블슈팅)

---

## 🗄️ 개요

Kubernetes 환경에서 MySQL Master-Slave 복제 구조를 구성합니다.

| 역할 | 환경 | 설명 |
|------|------|------|
| **Master** | Docker Compose (VM) | 데이터 쓰기(Write) 및 바이너리 로그 생성 |
| **Slave** | Kubernetes StatefulSet | 데이터 읽기(Read) 및 자동 동기화 |

---

## 🏗️ 구성

| 구성 요소 | 경로 |
|-----------|------|
| **Master** | `on-premise-ict/day7-1221/mysql/docker-compose.yml` |
| **Slave** | `on-premise-ict/day7-1221/mysql/mysql-slave-statefullset.yaml` |

---

## 🚀 빠른 시작

### 0️⃣ 사전 준비 (Pre-requisites)

StatefulSet에서 사용할 `hostPath` 디렉토리를 **모든 쿠버네티스 노드**에서 생성:

```bash
# 모든 노드에서 실행
for node in k8s-n1 k8s-n2 k8s-n3; do
  ssh $node "sudo mkdir -p /mnt/mysql-data-0 /mnt/mysql-data-1 && sudo chmod -R 777 /mnt/mysql-data-0 /mnt/mysql-data-1"
done
```

---

### 1️⃣ Master 설정 (VM - Docker Compose)

#### 1-1. 디렉토리 생성

```bash
mkdir -p ~/mysql/config ~/mysql/data ~/mysql/initdb.d ~/mysql/logs
sudo chown -R 999:999 ~/mysql/data ~/mysql/logs
```

#### 1-2. 설정 파일 복사

```bash
cp on-premise-ict/day7-1221/mysql/my.cnf ~/mysql/config/
cp on-premise-ict/day7-1221/mysql/docker-compose.yml ~/mysql/
```

#### 1-3. 초기화 SQL 생성

```bash
cd ~/mysql/initdb.d
cp on-premise-ict/day7-1221/mysql/.env ~/mysql/
export $(grep -v '^#' ~/mysql/.env | xargs)

cat <<EOF > setup.sql
CREATE USER '${USER_NAME}'@'%' IDENTIFIED WITH mysql_native_password BY '${USER_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${USER_NAME}'@'%' WITH GRANT OPTION;
CREATE USER '${REPL_NAME}'@'%' IDENTIFIED WITH mysql_native_password BY '${REPL_PASSWORD}';
GRANT REPLICATION SLAVE ON *.* TO '${REPL_NAME}'@'%';
FLUSH PRIVILEGES;
EOF
```

#### 1-4. 컨테이너 실행

```bash
cd ~/mysql
docker compose up -d
```

---

### 2️⃣ Slave 배포 (Kubernetes - StatefulSet)

```bash
cd ~/mysql
export $(grep -v '^#' .env | xargs)
envsubst < mysql-slave-statefullset.yaml | kubectl apply -f -
```

> [!NOTE]
> GTID 복제는 Master에 최소 하나의 트랜잭션이 있어야 정상 동작합니다.
> ```sql
> -- Master에서 테스트 DB 생성
> CREATE DATABASE test_db;
> ```

---

### 3️⃣ 복제 확인

```bash
# Slave 파드 접속
kubectl exec -it mysql-slave-0 -- mysql -u root -p${ROOT_PASSWORD}

# MySQL 내부에서 확인
SHOW SLAVE STATUS\G
```

---

### 4️⃣ Slave-1 server-id 변경 (Replicas > 1)

StatefulSet의 Replicas가 2 이상인 경우:

```bash
kubectl exec -it mysql-slave-1 -- mysql -u root -p${ROOT_PASSWORD}
```

```sql
SET GLOBAL server_id = 3;
STOP SLAVE;
START SLAVE;
SHOW SLAVE STATUS\G
```

---

## 🔧 트러블슈팅

### Slave 삭제 후 재배포

**1. 기존 리소스 삭제**

```bash
kubectl delete pv mysql-pv-0 mysql-pv-1
kubectl delete statefulset mysql-slave
kubectl delete svc mysql-slave-svc mysql-master-svc
kubectl delete configmap mysql-slave-config
kubectl delete pvc --all  # ⚠️ 주의: 데이터 삭제됨

# 호스트 데이터 삭제
for node in k8s-n1 k8s-n2 k8s-n3; do
  ssh $node "sudo rm -rf /mnt/mysql-data-0/* /mnt/mysql-data-1/*"
done
```

**2. .env 수정 후 재배포**

```bash
cd ~/mysql
vim .env  # MASTER_IP 등 수정
export $(grep -v '^#' .env | xargs)
envsubst < mysql-slave-statefullset.yaml | kubectl apply -f -
kubectl get all
```

**3. 복제 상태 확인**

```bash
kubectl exec -it mysql-slave-0 -- mysql -u root -p${ROOT_PASSWORD} -e "SHOW SLAVE STATUS\G"
# 또는
kubectl exec -it mysql-slave-0 -- mysql -u root -p${ROOT_PASSWORD} -e "STOP SLAVE; START SLAVE; SHOW SLAVE STATUS\G"
```
