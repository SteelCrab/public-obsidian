# Day 7 - DB 쿠버네티스 DB 복제 (DB Replication)

## 📚 목차

- [개요](#개요)
- [1️⃣ MySQL Master 설치 및 설정 (Docker Compose)](#1️⃣-mysql-master-설치-및-설정-docker-compose)
    - [1. Docker 설치](#1-docker-설치)
    - [2. MySQL Master 설치 및 설정](#2-mysql-master-설치-및-설정)
- [2️⃣ MySQL 복제 구성 (Kubernetes)](#2️⃣-mysql-복제-구성-kubernetes)
- [아키텍처](#아키텍처)
- [다음 단계](#다음-단계)

---

## 개요

Day 7에서는 Docker Compose를 이용한 단일 MySQL Master 구성과 Kubernetes 환경에서의 Primary-Secondary 복제(Replication) 구성을 다룹니다. 이를 통해 데이터 고가용성과 읽기 부하 분산을 실습합니다.

| 주제 | 설명 |
|------|------|
| **Docker Compose** | 로컬/실습 서버 환경에서의 빠른 Master DB 구성 |
| **K8s Replication** | Kubernetes 상의 Master(Write)와 Slave(Read) 동기화 |
| **Manifests** | Service, ConfigMap, Deployment를 통합한 선언적 배포 |

---

## 1️⃣ MySQL Master 설치 및 설정 (Docker Compose)

### 1. Docker 설치

Docker 패키지 저장소 접근을 위해 필요한 패키지를 설치하고 최신 버전을 유지합니다.

```bash
# HTTPS를 활용해 패키지 저장소에 접근하기 위해 패키지를 설치
sudo apt update
sudo apt -y install apt-transport-https ca-certificates gnupg lsb-release

# Docker의 공식 GPG키를 시스템에 추가
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Docker repository URL 등록 
sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 패키지 목록 갱신 및 Docker 설치
sudo apt update
sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 

# docker 버전 확인
docker version

# sudo 없이 실행하기 위해 현재 사용자를 docker 그룹에 추가
sudo usermod -a -G docker $USER

# 설정 적용을 위한 재부팅
sudo reboot
```

### 2. MySQL Master 설치 및 설정

Docker Compose를 사용하여 MySQL Master를 설치하고 데이터베이스 및 동기화용 계정을 초기화합니다.

**설치 및 초기화 스크립트**

```bash
# MySQL Master 설치 및 설정

# 1. 볼륨 디렉토리 생성 및 환경 파일 생성
mkdir -p ~/mysql/config ~/mysql/data ~/mysql/initdb.d ~/mysql/logs

# 2. (선택 사항) MySQL 컨테이너 유저가 쓸 수 있도록 권한 부여
# MySQL 공식 이미지의 유저 ID는 보통 999입니다.
sudo chown -R 999:999 ~/mysql/data ~/mysql/logs

# 3. 환경 설정 파일 생성 : ~/mysql/config/my.cnf
# (제공된 my.cnf 파일을 이 경로에 저장하세요)

# 4. 초기화 파일 생성 : ~/mysql/initdb.d/setup.sql
cd ~/mysql/initdb.d

# .env 파일에서 변수 로드 (initdb.d와 같은 경로에 .env가 있는 경우)
export $(grep -v '^#' .env | xargs)

# 만약 .env가 상위 디렉토리(~/mysql)에 있다면 아래 명령어를 사용하세요.
# export $(grep -v '^#' ../.env | xargs)

# 파일 생성
cat <<EOF > setup.sql
CREATE USER '${USER_NAME}'@'%' IDENTIFIED WITH mysql_native_password BY '${USER_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${USER_NAME}'@'%' WITH GRANT OPTION;
CREATE USER '${REPL_NAME}'@'%' IDENTIFIED WITH mysql_native_password BY '${REPL_PASSWORD}';
GRANT REPLICATION SLAVE ON *.* TO '${REPL_NAME}'@'%';
FLUSH PRIVILEGES;
EOF

# 컨테이너 올리기
docker compose up -d

# 외부에서 접속하는 것과 동일한 효과를 내기 위해 -h 옵션을 사용합니다.
mysql -h 172.100.100.21 -u ian -p***REMOVED*** -e "SELECT VERSION();"

# ============================
# 결과가 안나올 경우
# 로그확인 : tail -n 50 ~/mysql/logs/error.log
# 1. 컨테이너 중지 및 볼륨 삭제
cd ~/mysql-master
docker compose down -v

# 2. 호스트의 데이터 폴더 수동 삭제 (잔여물 제거)
sudo rm -rf ~/mysql/data/*

# 3. 다시 실행 (이때 setup.sql이 반드시 실행됩니다)
docker compose up -d
# ================= 
```

### 환경 설정 (`my.cnf`)

`~/mysql/config/my.cnf` 파일의 주요 설정 내용입니다.

```ini
[mysqld]
# Master 복제 설정
server-id = 1                # 마스터 고유 ID
log-bin = mysql-bin          # 바이너리 로그 활성화
binlog_format = ROW          # 행 기반 복제
gtid_mode = ON               # GTID 사용
enforce_gtid_consistency = ON
character-set-server = utf8mb4
default-time-zone = '+09:00'
```

---

## 2️⃣ MySQL 복제 구성 (Kubernetes)

Kubernetes 환경에서 통합된 매니페스트를 사용하여 Master-Slave 복제 구조를 구성합니다.

### 디렉토리 구조

```
on-premise-ict/day7-1221/mysql/
├── mysql-master.yaml   # Master 구성 (Service + ConfigMap + Deployment)
└── mysql-slave.yaml    # Slave 구성 (Service + ConfigMap + Deployment)
```

### Kubernetes 리소스

| 리소스 | 파일 | 설명 |
|--------|------|------|
| **Master 구성** | `mysql-master.yaml` | Service(172.100.100.20), ConfigMap, Deployment |
| **Slave 구성** | `mysql-slave.yaml` | Service(172.100.100.21), ConfigMap, Deployment |

### 배포 방법

```bash
# 1. Namespace 생성
kubectl create namespace db-replication

# 2. Master 배포 (Service, ConfigMap 포함)
envsubst < mysql/mysql-master.yaml | kubectl apply -f -

# 3. Slave 배포 (Service, ConfigMap 포함)
envsubst < mysql/mysql-slave.yaml | kubectl apply -f -
```

---

## 아키텍처

### Replication 흐름 및 IP 구성

```mermaid
flowchart TB
    User[Client/App]
    
    subgraph K8s[Kubernetes Cluster]
        subgraph MasterService[Service: mysql-master]
            M_SVC[IP: 172.100.100.20]
        end
        
        subgraph SlaveService[Service: mysql-slave]
            S_SVC[IP: 172.100.100.21]
        end
        
        subgraph MasterPod[Pod: mysql-master]
            M_DB[(MySQL Primary)]
        end
        
        subgraph SlavePod[Pod: mysql-slave]
            S_DB[(MySQL Replica)]ㅉ
        end
        
        User -->|Write| M_SVC
        User -->|Read| S_SVC
        
        M_SVC --> M_DB
        S_SVC --> S_DB
        
        M_DB -- Async Replication --> S_DB
    end
```

---

## 다음 단계

1. ✅ Docker를 이용한 Master DB 기본 설정 완료
2. ✅ Kubernetes Master/Slave 배포
3. ✅ Service 접속 및 LoadBalancer IP 확인
4. 🔄 데이터 동기화(`SHOW SLAVE STATUS`) 테스트
