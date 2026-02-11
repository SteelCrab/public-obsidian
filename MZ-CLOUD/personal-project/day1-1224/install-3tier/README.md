# Day 1 - 3-Tier 구축 (VMware)

> bastion, nfs, mysql, k8s-master, k8s-node1, k8s-node2, k8s-node3

## 📋 목차

1. [🗄️ 개요](#🗄️-개요)
2. [🏗️ 인프라 구성](#🏗️-인프라-구성)
   - [전체 VM 구성표](#전체-vm-구성표)
3. [🏢 Base VM 준비](#🏢-base-vm-준비)
   - [기본 패키지 설치](#기본-패키지-설치)
   - [VM 클론 워크플로](#vm-클론-워크플로)
4. [🖥️ Bastion Host 구성](#🖥️-bastion-host-구성)
   - [1. hostname 설정](#1-hostname-설정)
   - [2. ip 설정](#2-ip-설정)
   - [3. ssh 설정](#3-ssh-설정)
   - [4. 규칙 저장](#4-규칙-저장)
   - [5. 게이트웨이 설정](#5-게이트웨이-설정)
5. [🔌 NFS System 구성](#🔌-nfs-system-구성)
   - [1. hostname 설정](#1-hostname-설정-1)
   - [2. 네트워크 설정](#2-네트워크-설정)
   - [3. ssh 설정](#3-ssh-설정-1)
   - [4. 설정 적용](#4-설정-적용)
   - [5. 추가 디스크 공간 마운트](#5-추가-디스크-공간-마운트)
   - [6. nfs 서버 설치](#6-nfs-서버-설치)
   - [7. 최종 확인](#7-최종-확인-nfs-서버가-아닌-k8s-노드에서-실행)
   - [8. NFS 종료 (Unmount & Stop)](#8-nfs-종료-unmount--stop)
6. [🗃️ MySQL 구성](#🗃️-mysql-구성)
   - [1. 선행: NFS 초기 설치](#1선행-nfs-초기-설치-구성과-같음)
   - [2. Docker 설치](#2-docker-설치)
   - [3. mysqlMaster 설정](#3-mysqlmaster-설정)
   - [4. docker compose 설정](#4-docer-compose-설정)
   - [5. MySQL 접속 확인](#5-mysql-접속-및-작동-확인)
7. [⚙️ k8s-m 설정](#⚙️-k8s-m-설정)
   - [1. ssh 설정](#1-ssh-설정)
   - [2. 네트워크 설정](#2-네트워크-설정-1)
   - [3. 호스트네임 설정](#3-호스트네임-설정)
   - [4. hosts 설정](#4-hosts-설정)
   - [5. 시스템 설정](#5-시스템-설정)
   - [6. 커널 설정](#6-커널-설정)
   - [7. Docker 엔진 설치](#7-docker-엔진-설치)
   - [8. containerd 설정](#8-containerd-설정)
   - [9. Kubernetes 설치](#9-kubernetes-설치)
8. [🔄 k8s-n1,n2,n3 클론 (vmware)](#🔄-k8s-n1n2n3-클론-vmware)
   - [VMWARE 작업](#vmware-작업)
   - [n1,n2,n3 설정](#n1n2n3-설정)
   - [NFS 마운트 (워커 노드)](#nfs-마운트-워커-노드)
   - [6. 마스터 노드 초기화](#6-마스터-노드-초기화)
   - [kubectl 설정](#kubectl-설정)
   - [자동완성 및 alias](#자동완성-및-alias)
   - [각 워커 노드에서 실행](#각-워커-노드에서-실행)
   - [calico 네트워크 플러그인 설치](#calico-네트워크-플러그인-설치)
   - [상태 확인](#상태-확인)
9. [📡 Ingress Controller 구성](#📡-ingress-controller-구성)
   - [1. Helm 설치](#1-helm-설치)
   - [2. Ingress-NGINX 설치 (Helm)](#2-ingress-nginx-설치-helm)
   - [3. 설치 확인](#3-설치-확인)
   - [4. Ingress 리소스 예시](#4-ingress-리소스-예시)
   - [5. 접속 테스트](#5-접속-테스트)
10. [🔗☸ MetalLB 구성](#🔗☸-metallb-구성)
    - [1. MetalLB 설치](#1-metallb-설치)
    - [2. IP Pool 설정](#2-ip-pool-설정)
    - [3. LoadBalancer 테스트](#3-loadbalancer-테스트)
11. [🦊 GitLab Self-Hosted Runner 구축](#🦊-gitlab-self-hosted-runner-구축)
    - [인프라 정보](#📁-인프라-정보)
    - [Docker 설치 (필수)](#📦-docker-설치-필수)
    - [GitLab Runner 설치](#🏃-gitlab-runner-설치)
12. [⚙️ Kubeconfig 설정](#⚙️-kubeconfig-설정)
    - [환경 정보](#📁-환경-정보)
    - [1. K8s Master에서 kubeconfig 확인](#1-k8s-master에서-kubeconfig-확인)
    - [2. GitLab Runner VM에서 kubeconfig 복사](#2-gitlab-runner-vm에서-kubeconfig-복사)
    - [3. kubeconfig 수정](#3-kubeconfig-수정-⚠️-중요)
    - [4. 접속 테스트](#4-접속-테스트)
    - [5. 자동 배포 설정](#5-자동-배포-설정-cicd)
13. [🔐 SSH 터널링 설정](#🔐-ssh-터널링-설정)
    - [SSH 명령어 분석](#ssh-명령어-분석)
    - [~/.ssh/config 설정](#sshconfig-설정)
14. [🔄 GitLab Mirror 동기화](#🔄-gitlab-mirror-동기화)
    - [구조 설명](#구조-설명)
    - [Self-Hosted Token 생성](#1-self-hosted-token-생성)
    - [동기화 스크립트 설정](#2-동기화-스크립트-설정)
15. [🏢 Container Registry 설정](#🏢-container-registry-설정)
    - [Insecure Registry 설정](#1-insecure-registry-설정)
    - [Registry Token 생성](#2-registry-token-생성)
    - [이미지 Push 테스트](#3-이미지-push-테스트)
    - [K8s에서 Private Registry 사용 설정](#4-k8s에서-private-registry-사용-설정)
16. [🔚 관련 파일](#🔚-관련-파일)
17. [📚 참고 사항](#📚-참고-사항)
18. [⚠️ 오류 해결](#⚠️-오류-해결)
    - [SSH 서비스 실패](#ssh-서비스-실패-sshd-no-hostkeys-available)
    - [Docker Registry HTTPS 오류](#docker-registry-https-오류)
    - [Docker Registry 접근 거부](#docker-registry-접근-거부)

---

## 🗄️ 개요
VMware 환경에서 3-Tier 아키텍처 구축을 위한 가이드입니다.

---

## 🏗️ 인프라 구성

### 전체 VM 구성표

| VMware | Processors | Memory | Hostname | IP | extPort | Storage |
| :--- | :---: | :---: | :--- | :--- | :---: | :--- |
| GitLab | 2 | 2048 MB | gitlab | 172.100.100.8 | 22, 80, 443 | 30Gi / 50Gi |
| Bastion | 1 | 1024 MB | bastion | 10.100.0.9 / 172.100.100.9 | 22 | 30Gi |
| NFS | 1 | 1024 MB | nfs | 172.100.100.10 | 22 | 30Gi / 50Gi |
| MySQL | 2 | 4096 MB | mysql | 172.100.100.11 | 22 | 30Gi / 50Gi |
| k8s-Master | 2 | 4096 MB | k8s-m | 172.100.100.12 | 22 | 30Gi |
| k8s-Node1 | 2 | 4096 MB | k8s-n1 | 172.100.100.13 | 22 | 30Gi / 50Gi |
| k8s-Node2 | 2 | 4096 MB | k8s-n2 | 172.100.100.14 | 22 | 30Gi / 50Gi |
| k8s-Node3 | 2 | 4096 MB | k8s-n3 | 172.100.100.15 | 22 | 30Gi / 50Gi |

> [!NOTE]
> **IP 참조**: Kubernetes CNI와 충돌 방지
> - Flannel: `10.244.0.0/16`
> - Weave Net: `10.32.0.0/12`
> - Calico: `192.168.0.0/16`
> - Cilium: 유연

---

## 🏢 Base VM 준비

### 기본 패키지 설치

```bash
sudo apt update
sudo apt install -y vim net-tools openssh-server ssh tree htop curl open-vm-tools nfs-common
```

### VM 클론 워크플로

```
A. 기본 패키지가 설치된 Ubuntu VM 준비 (Default Ubuntu)
   └── 두 번째 Storage(50Gi)는 마운트하지 않은 상태로 유지

B. VM 복제 및 구성
   ├── a) GitLab Server (172.100.100.8)
   │    └── Default clone → VM rename → Storage Mount → hostname/IP 설정
   │    └── GitLab CE + Runner 설치
   │
   ├── b) Bastion Host (172.100.100.9)
   │    └── Default clone → 50G Storage 제거 → VM rename → hostname/IP 설정
   │
   ├── c) NFS Server
   │    └── Default clone → VM rename → Storage Mount → hostname/IP 설정
   │
   ├── d) MySQL Master
   │    └── Default clone → VM rename → Storage Mount → hostname/IP 설정
   │
   ├── e) k8s-Master
   │    └── Default clone → VM rename → Storage Mount → hostname/IP 설정
   │    └── kubeadm init 이전까지 구성
   │
   └── f) k8s-Worker Nodes
         └── k8s-Master clone → VM rename → 노드1 hostname/IP 설정
         └── 노드1 clone → 노드2,3 → hostname/IP 설정
```

---
## 🖥️ Bastion Host 구성

### 1. hostname 설정 

```
sudo hostnamectl set-hostname bastion
```
### 2. ip 설정 

```
sudo vi /etc/netplan/50-cloud-init.yaml

network:
  version: 2
  ethernets:
    ens33:
      addresses:
      - "172.100.100.9/24"
      routes:
      - to: "default"
        via: "172.100.100.2"
    ens34:
      addresses:
      - "192.168.5.9/24"
      nameservers:
        addresses:
        - 8.8.8.8
        search:
        - 8.8.4.4
      routes:
      - to: "default"
        via: "192.168.5.2"
```
### 3. ssh 설정 

```
sudo vi /etc/ssh/sshd_config


```


### 1. IP 포워딩 활성화

```
sudo vi /etc/sysctl.conf

#net.ipv4.ip_forward=1 주석 제거
```
### 변경사항 적용

```
sudo sysctl -p
```

### 2.ens33의 내부(인터넷) 접속을 인터넷 인터페이스입니다.

```
sudo iptables -t nat -A POSTROUTING -o ens34 -j MASQUERADE
```

### 3.트래픽 전달 허용 규칙 (기본값이 DROP인 경우 필요)

```
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i ens33 -o ens34 -j ACCEPT
```

### 4. 규칙 저장

```
sudo apt install -y iptables-persistent
sudo netfilter-persistent save
```
---

### 5. 게이트웨이 설정 

> 내부 인스턴스(NFS, Mysql, k8s) 설정

```
routes:
  - to: default
    via: 172.100.100.9  # Bastion의 내부 IP
```
### hosts 설정 
```
sudo echo '172.100.100.10 nfs' | sudo tee -a /etc/hosts
sudo echo '172.100.100.11 mysql' | sudo tee -a /etc/hosts
sudo echo '172.100.100.12 k8s-m' | sudo tee -a /etc/hosts
sudo echo '172.100.100.13 k8s-n1' | sudo tee -a /etc/hosts
sudo echo '172.100.100.14 k8s-n2' | sudo tee -a /etc/hosts
sudo echo '172.100.100.15 k8s-n3' | sudo tee -a /etc/hosts
```

---

## 🔌 NFS System 구성

### 1. hostname 설정 

```
sudo hostnamectl set-hostname nfs
```
### 2. 네트워크 설정 

```
sudo vi /etc/netplan/50-cloud-init.yaml

network:
  version: 2
  ethernets:
    ens33:
      addresses:
      - "172.100.100.10/24"
      nameservers:
        addresses:
        - 8.8.8.8
        - 8.8.4.4
      routes:
      - to: "default"
        via: "172.100.100.9"

sudo netplan apply
```

### 3. ssh 설정 

```
sudo vi /etc/ssh/sshd_config

# 42 PermitRootLogin no
# 47 PubkeyAuthentication no
# 66 PasswordAuthentication yes
# 67 PermitEmptyPasswords no
```

```
# PermitRootLogin no (주석 제거 + 값 변경)
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# PubkeyAuthentication no
sudo sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication no/' /etc/ssh/sshd_config

# PasswordAuthentication yes
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# PermitEmptyPasswords no
sudo sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config

# 적용
sudo systemctl restart ssh.service
```

### 4. 설정 적용

```
sudo systemctl restart ssh.service
```

### 5. 추가 디스크 공간 마운트
```
lsblk
sdb                    8:16   0   50G  0 disk

# 파일시스템 설정

sudo mkfs.ext4 /dev/sdb

# 데이터 공간 생성
sudo mkdir /mnt/DATA-

# 마운트
sudo mount /dev/sdb /mnt/DATA

# 마운트 확인
df -h /mnt/DATA

# 권한 설정
sudo chown -R nobody:nogroup /mnt/DATA
sudo chmod -R 777 /mnt/DATA

# 부팅시 자동 설정 
sudo blkid /dev/sdb
/dev/sdb: UUID="066ba897-ab10-4740-99df-b5da2fd0b7dd" BLOCK_SIZE="4096" TYPE="ext4"

# 옵션 1 : vi 사용
#sudo vi /etc/fstab
#UUID=066ba897-ab10-4740-99df-b5da2fd0b7dd /mnt/DATA ext4 defaults 0 2

# or 

# 옵션 2 : sh 사용
sudo sh -c 'echo "UUID=066ba897-ab10-4740-99df-b5da2fd0b7dd /mnt/DATA ext4 defaults 0 2" >> /etc/fstab'

```

### 6. nfs 서버 설치

```
# 패키지 설치 
sudo apt update
sudo apt install -y nfs-kernel-server

# 공유 디렉토리 생성 및 권한 설정
sudo mkdir -p /mnt/DATA
sudo chown -R nobody:nogroup /mnt/DATA
sudo chmod -R 777 /mnt/DATA

# 1. NFS 공유 설정(Exports)
echo '/mnt/DATA 172.100.100.0/24(rw,sync,no_subtree_check,no_root_squash)' | sudo tee -a /etc/exports

# 2. exports 파일 적용
sudo exportfs -ra

# 3. 서비스 재시작
sudo systemctl restart nfs-kernel-server

# 4. 서비스가 잘 돌아가고 있는지 확인 (Active: active (running) 확인)
sudo systemctl status nfs-kernel-server

# 5. 공유 상태 확인
sudo exportfs -v
```

### 7. 최종 확인 NFS 서버가 아닌 k8s 노드(172.100.100.3,5~9)에서 실행

> 기선 NFS 서버를 제외한 모든 생성된 또는 생성할 인스턴스에 NFS 사용을 위한 클라이언트용 필수 패키지를 설치해 줍니다.

```
sudo apt update
sudo apt install -y nfs-common
showmount -e 172.100.100.10
---
Export list for 172.100.100.10:
/mnt/DATA 172.100.100.0/24
---

# 1. 마운트 포인트 생성
sudo mkdir -p /mnt/DATA

# 2. NFS 마운트
sudo mount -t nfs 172.100.100.10:/mnt/DATA /mnt/DATA

# 3. 확인
ls -al /mnt/DATA
df -h /mnt/DATA

#4. 부팅시 자동 마운트
echo '172.100.100.10:/mnt/DATA /mnt/DATA nfs defaults 0 0' | sudo tee -a /etc/fstab

```

### 8. NFS 종료 (Unmount & Stop)

> NFS 클라이언트에서 마운트 제거 후 NFS 서버를 종료하는 방법

#### 클라이언트에서 마운트 제거

```bash
# 1. 마운트 제거
sudo umount /mnt/DATA

# 2. 자동 마운트 설정 제거 (필요시)
sudo sed -i '/nfs:\/mnt\/DATA/d' /etc/fstab

# 3. 마운트 제거 확인
df -h | grep DATA
```

#### NFS 서버 종료

```bash
# 1. NFS 서비스 종료
sudo systemctl stop nfs-kernel-server

# 2. 서비스 비활성화 (부팅시 자동 시작 방지)
sudo systemctl disable nfs-kernel-server

# 3. 상태 확인
sudo systemctl status nfs-kernel-server
```

#### NFS 서버 재시작

```bash
# 서비스 활성화 및 시작
sudo systemctl enable nfs-kernel-server
sudo systemctl start nfs-kernel-server
```

---

## 🗃️ MySQL 구성

### 1.선행: NFS 초기 설치 구성과 같음 

### 2. Docker 설치 

```
# HTTPS를 사용해 패키지와 리소스 접근하기 위해 패키지를 설치
sudo apt update

# Docker 설치에 필요한 패키지들 설치
sudo apt -y install apt-transport-https ca-certificates gnupg lsb-release

# Docker의 공식 GPG키를 시스템에 추가.
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Docker를 repository URL 등록 
sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 새로운 리소스가 추가되었으므로 repository update를 통해 패키지 목록 갱신
sudo apt update

# docker, containerd.io 설치.
sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 

# docker 버전확인을 통한 설치 완료 확인
docker version

# docker 명령어를 sudo 없이 실행하기 위해 현재 사용자를 docker 그룹에 추가
sudo usermod -a -G docker $USER

# 설정 적용을 위한 리부팅
sudo reboot
```

### 3. NFS 설정 
### 3. mysqlMaster 설정 

```
# 1. 볼륨 디렉토리 생성 및 환경 파일 생성
rm -rf /mnt/DATA/mysql/*

mkdir -p /mnt/DATA/mysql/config 
mkdir -p /mnt/DATA/mysql/data 
mkdir -p /mnt/DATA/mysql/initdb.d 
mkdir -p /mnt/DATA/mysql/logs

# 2. (선택 사항) MySQL 컨테이너 유저가 쓸 수 있도록 권한 부여
# MySQL 공식 이미지의 유저 ID는 보통 999입니다.
sudo chown -R 999:999 /mnt/DATA/mysql/data 
sudo chown -R 999:999 /mnt/DATA/mysql/logs

# 3. 환경 설정 파일 생성 : /mnt/DATA/mysql/config/my.cnf
sudo tee /mnt/DATA/mysql/config/my.cnf > /dev/null <<EOF
[mysqld]
server-id = 1
gtid_mode = ON
enforce_gtid_consistency = ON
log_bin = mysql-bin
binlog_format = ROW
skip_host_cache
skip_name_resolve
EOF

# 4. 초기 sql 파일 생성 : /mnt/DATA/mysql/initdb.d/init.sql

sudo tee /mnt/DATA/mysql/initdb.d/init.sql > /dev/null <<EOF
CREATE USER 'pista'@'%' IDENTIFIED WITH mysql_native_password BY '<YOUR_PASSWORD>';
GRANT ALL PRIVILEGES ON *.* TO 'pista'@'%' WITH GRANT OPTION;
CREATE USER 'repl_pista'@'%' IDENTIFIED WITH mysql_native_password BY '<YOUR_PASSWORD>';
GRANT REPLICATION SLAVE ON *.* TO 'repl_pista'@'%';
FLUSH PRIVILEGES;
EOF
```

### 4. docer compose 설정 

```
sudo tee /mnt/DATA/mysql/docker-compose.yml > /dev/null <<EOF
version: '3.8'
services:
  mysql-master:
    image: mysql:8.0
    container_name: mysql-master
    restart: always
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: <YOUR_PASSWORD>
      TZ: Asia/Seoul
    volumes:
      # 1. 전경 설정 파일
      - /mnt/DATA/mysql/config/my.cnf:/etc/mysql/conf.d/my.cnf:ro
      # 2. 데이터 저장 설정
      - /mnt/DATA/mysql/data:/var/lib/mysql
      # 3. 로그 저장
      - /mnt/DATA/mysql/logs:/var/log/mysql
      # 4. 초기 sql 파일
      - /mnt/DATA/mysql/initdb.d:/docker-entrypoint-initdb.d
    networks:
      - mysql-network
networks:
  mysql-network:
    driver: bridge
EOF
```

### 5. MySQL 접속 및 작동 확인

#### VM 내부에서 접속 확인 (Docker Container 안에서)
```bash
docker exec -it mysql-master mysql -u pista -p<YOUR_PASSWORD>
```

#### 다른 VM(Host)에서 접속 확인
MySQL 클라이언트 패키지가 설치되어 있어야 됩니다.
```bash
# 클라이언트 설치
sudo apt update && sudo apt install -y mysql-client

# 접속 테스트 (MySQL VM IP: 172.100.100.11)
mysql -h 172.100.100.11 -u pista -p<YOUR_PASSWORD>
```

#### 외부 (Windows/GUI)에서 접속
- **Host**: `172.100.100.11` (VMware VM IP)
- **Port**: `3306`
- **User**: `pista`
- **Password**: `<YOUR_PASSWORD>`

---

## ⚙️ k8s-m 설정

### 1. ssh 설정 

```
```
### 2. 네트워크 설정 

```
sudo vi /etc/netplan/50-cloud-init.yaml
```

### 3. 호스트네임 설정 

```
sudo hostnamectl set-hostname k8s-m
```

### 4. hosts 설정 

```
sudo echo '172.100.100.12 k8s-m' | sudo tee -a /etc/hosts
sudo echo '172.100.100.13 k8s-n1' | sudo tee -a /etc/hosts
sudo echo '172.100.100.14 k8s-n2' | sudo tee -a /etc/hosts
sudo echo '172.100.100.15 k8s-n3' | sudo tee -a /etc/hosts
```

### 5. 시스템 설정 

```
# 시간대 설정
sudo timedatectl set-timezone Asia/Seoul

# 스왑 비활성화
# swap 라인 주석 처리 (파일명 무관)
sudo sed -i '/swap/s/^/#/' /etc/fstab
# 확인
cat /etc/fstab

```


### 6. 커널 설정

```bash
# IP 포워딩 활성화
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 모듈 로드
sudo modprobe overlay
sudo modprobe br_netfilter

# 저장 설정
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# sysctl 설정
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# 적용
sudo sysctl --system
```

### 7. Docker 엔진 설치

```bash
# 필수 패키지
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# Docker GPG 키
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Docker 리포지토리
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Docker 설치
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 사용자 그룹 추가
sudo usermod -aG docker $USER
# 바로 재시작
sudo reboot
```

### 8. containerd 설정 

```bash
# config.toml 생성
sudo sh -c "containerd config default > /etc/containerd/config.toml"

# SystemdCgroup 활성화
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# daemon.json 설정
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {"max-size": "100m"},
  "storage-driver": "overlay2"
}
EOF

# 서비스 재시작
sudo systemctl daemon-reload
sudo systemctl enable docker containerd
sudo systemctl restart docker containerd
```

### 9. Kubernetes 설치

```bash
# 리포지토리 추가
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 패키지 설치
sudo apt update
sudo apt install -y kubelet kubeadm kubectl

# 버전 고정
sudo apt-mark hold kubelet kubeadm kubectl

# 서비스 시작
sudo systemctl daemon-reload
sudo systemctl enable --now kubelet

# 버전 확인
kubelet --version
kubeadm version
kubectl version --client
```

## 🔄 k8s-n1,n2,n3 클론 (vmware)

### VMWARE 작업 
- [ ] k8s-m에서 k8s-n1,n2,n3을 vmware로 클론 
- [ ] 스냅샷 생성(vmestr)
- [ ] k8s-n1,n2,n3에서 MAC 주소 변경

### n1,n2,n3 설정

```bash


# 호스트 이름 변경
sudo hostnamectl set-hostname k8s-n1
sudo hostnamectl set-hostname k8s-n2
sudo hostnamectl set-hostname k8s-n3

# 네트워크 설정 
sudo vi /etc/netplan/50-cloud-init.yaml

sudo netplan apply



# 기존 키 삭제
rm -f ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub
# 새 키 생성
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
# 확인
cat ~/.ssh/id_ed25519.pub

# 각 노드에 키 배포
ssh-copy-id pista@k8s-n1
ssh-copy-id pista@k8s-n2
ssh-copy-id pista@k8s-n3


# SSH로 sudoers 설정 (-t 옵션 사용)
for node in k8s-n1 k8s-n2 k8s-n3; do
  ssh -t $node "echo 'pista ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/pista"
done

# k8s-m에서 실행
for node in k8s-n1 k8s-n2 k8s-n3; do
  ssh $node "sudo locale-gen ko_KR.UTF-8 && sudo update-locale LANG=ko_KR.UTF-8"
done

# 패키지 업데이트
for node in k8s-m k8s-n1 k8s-n2 k8s-n3; do
  ssh $node "sudo apt update -y && sudo apt upgrade -y"
done

# 스왑 비활성화
for node in k8s-m k8s-n1 k8s-n2 k8s-n3; do
  ssh $node "sudo swapoff -a"
  ssh $node "sudo sed -i '/swap/s/^/#/' /etc/fstab"
done

# 필요한 apt 패키지 설치 
for node in k8s-m k8s-n1 k8s-n2 k8s-n3; do
  ssh $node "sudo apt install -y vim net-tools openssh-server ssh tree htop curl open-vm-tools nfs-common git"
done

```

### NFS 마운트 (워커 노드)

> k8s-m에서 실행하여 모든 워커 노드에 NFS 마운트

```bash
for node in k8s-n1 k8s-n2 k8s-n3; do
  ssh $node "sudo mkdir -p /mnt/DATA && sudo mount -t nfs 172.100.100.10:/mnt/DATA /mnt/DATA"
  ssh $node "grep -q 'nfs' /etc/fstab || echo '172.100.100.10:/mnt/DATA /mnt/DATA nfs defaults 0 0' | sudo tee -a /etc/fstab"
done
```

### 6. 마스터 노드 초기화

```bash
# kubeadm init
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.100.100.12

# 출력된 kubeadm join 명령어 저장!
```

### kubectl 설정

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 자동완성 및 alias

```bash
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc
source ~/.bashrc
```

### 각 워커 노드에서 실행

```bash
# kubeadm init 시 출력된 명령어 사용
sudo kubeadm join 172.100.100.12:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
```

### calico 네트워크 플러그인 설치

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml
```

### 상태 확인

```bash
kubectl get nodes
kubectl get pods -A
```

---

## 📡 Ingress Controller 구성

### 1. Helm 설치

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

### 2. Ingress-NGINX 설치 (Helm)

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

kubectl create namespace ingress
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress
```

### 3. 설치 확인

```bash
kubectl get pods -n ingress
kubectl get svc -n ingress
```

### 4. Ingress 리소스 예시

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  namespace: default
spec:
  ingressClassName: nginx
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

### 5. 접속 테스트

```bash
# Ingress Controller의 NodePort 확인
kubectl get svc -n ingress

# 테스트
curl -H "Host: app.example.com" http://<NODE_IP>:<NODE_PORT>
```

---

## 🔗☸ MetalLB 구성

### 1. MetalLB 설치

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml
```

### 2. IP Pool 설정

```yaml
# metallb-pool.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.100.100.200-172.100.100.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
```

```bash
kubectl apply -f metallb-pool.yaml
```

### 3. LoadBalancer 테스트

```bash
kubectl get svc -A | grep LoadBalancer
```

---

## 🦊 GitLab Self-Hosted Runner 구축

### 📁 인프라 정보

| 항목 | 값 |
|------|-----|
| GitLab Server | 172.100.100.8 |
| K8s API Server | 172.100.100.12:6443 |

### 📦 Docker 설치 (필수)

```bash
# Docker GPG 키
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Docker 리포지토리
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Docker 설치
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# 사용자 그룹 추가
sudo usermod -aG docker $USER
newgrp docker
```

### 🏃 GitLab Runner 설치

```bash
# GitLab Runner 리포지토리
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash

# 설치
sudo apt install gitlab-runner

# 등록
sudo gitlab-runner register \
  --non-interactive \
  --url "http://172.100.100.8" \
  --token "<RUNNER_TOKEN>" \
  --executor "docker" \
  --docker-image "docker:24.0.5" \
  --description "docker-runner"

# 확인
sudo gitlab-runner list
```

---

## ⚙️ Kubeconfig 설정

### 📁 환경 정보

| 항목 | 값 |
|------|-----|
| K8s Master | 172.100.100.12:6443 |
| GitLab Runner | 172.100.100.8 |

### 1. K8s Master에서 kubeconfig 확인

```bash
cat ~/.kube/config
```

### 2. GitLab Runner VM에서 kubeconfig 복사

```bash
mkdir -p ~/.kube
scp pista@172.100.100.12:~/.kube/config ~/.kube/config
```

### 3. kubeconfig 수정 (⚠️ 중요)

```bash
vim ~/.kube/config
```

`server:` 항목을 수정:
```yaml
server: https://172.100.100.12:6443  # localhost 대신 실제 Master IP
```

### 4. 접속 테스트

```bash
kubectl get nodes
```

### 5. 자동 배포 설정 (CI/CD)

```yaml
# .gitlab-ci.yml
deploy:
  stage: deploy
  script:
    - kubectl apply -f k8s/
  only:
    - main
```

---

## 🔐 SSH 터널링 설정

### SSH 명령어 분석

```bash
ssh -L 8080:172.100.100.20:80 -J pista@192.168.5.9 pista@172.100.100.12
```

| 옵션 | 설명 |
|------|------|
| `-L 8080:172.100.100.20:80` | 로컬 포트 8080을 원격 172.100.100.20:80에 포워딩 |
| `-J pista@192.168.5.9` | Bastion(Jump) 서버 경유 |
| `pista@172.100.100.12` | 최종 대상 서버 |

### ~/.ssh/config 설정

```
Host bastion
    HostName 192.168.5.9
    User pista

Host k8s-m
    HostName 172.100.100.12
    User pista
    ProxyJump bastion
```

```bash
ssh k8s-m
```

---

## 🔄 GitLab Mirror 동기화

### 구조 설명

Cloud GitLab에서 Self-Hosted GitLab으로 미러링합니다.

### 1. Self-Hosted Token 생성

GitLab Web UI → User Settings → Access Tokens
- Scope: `write_repository`

### 2. 동기화 스크립트 설정

```bash
# 미러 클론
git clone --mirror https://oauth2:<CLOUD_TOKEN>@gitlab.com/<user>/<repo>.git repo.git

# Cron 등록
*/5 * * * * cd /opt/mirror/repo.git && git fetch --all && git push --mirror http://oauth2:<SELF_TOKEN>@172.100.100.8/<user>/<repo>.git
```

---

## 🏢 Container Registry 설정

### 1. Insecure Registry 설정

```bash
# /etc/docker/daemon.json
{
  "insecure-registries": ["172.100.100.8:5050"]
}
sudo systemctl restart docker
```

### 2. Registry Token 생성

GitLab Web UI → User Settings → Access Tokens
- Scope: `read_registry`, `write_registry`

### 3. 이미지 Push 테스트

```bash
docker login 172.100.100.8:5050
docker tag myimage:latest 172.100.100.8:5050/root/myproject/myimage:latest
docker push 172.100.100.8:5050/root/myproject/myimage:latest
```

### 4. K8s에서 Private Registry 사용 설정

```bash
kubectl create secret docker-registry gitlab-registry \
  --docker-server=172.100.100.8:5050 \
  --docker-username=root \
  --docker-password=<TOKEN> \
  -n gition
```

---

## 🔚 관련 파일

| 파일 | 설명 |
|------|------|
| `3-tier.ini` | 환경 변수 설정 파일 |
| `test-nginx.yaml` | Nginx 테스트 배포 매니페스트 |

---

## 📚 참고 사항

- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [GitLab Runner 설치 가이드](https://docs.gitlab.com/runner/install/)
- [MetalLB 문서](https://metallb.universe.tf/)

---

## ⚠️ 오류 해결

### SSH 서비스 실패 (sshd: no hostkeys available)

**오류:** `sshd: no hostkeys available`

**해결:**
```bash
sudo ssh-keygen -A
sudo systemctl restart ssh
```

### Docker Registry HTTPS 오류

**오류:** `http: server gave HTTP response to HTTPS client`

**해결:** insecure-registries 설정 추가 (위 참조)

### Docker Registry 접근 거부

**오류:** `unauthorized: access denied`

**해결:**
1. Access Token 재발급
2. `docker login` 재실행
3. K8s Secret 재생성
