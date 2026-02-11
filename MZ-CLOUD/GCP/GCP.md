# GCP 사용기 
#gcp #cloud 
```table-of-contents
```
## gcloud CLI 설치

### macOS
```bash
# Homebrew로 설치
brew install --cask google-cloud-sdk

# 또는 공식 스크립트로 설치
curl https://sdk.cloud.google.com | bash

# 셸 재시작
exec -l $SHELL

# 초기화
gcloud init
```

### Linux (Debian/Ubuntu)
```bash
# 패키지 소스 추가
sudo apt-get install -y apt-transport-https ca-certificates gnupg curl

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
    https://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

# 설치
sudo apt-get update && sudo apt-get install -y google-cloud-cli

# 초기화
gcloud init
```

### 설치 확인 및 초기 설정
```bash
# 버전 확인
gcloud version

# 인증 (브라우저 로그인)
gcloud auth login

# 프로젝트 설정
gcloud config set project <PROJECT_ID>

# 기본 리전/존 설정
gcloud config set compute/region asia-northeast1
gcloud config set compute/zone asia-northeast1-a

# 설정 확인
gcloud config list
```

---

## AWS vs GCP
| **구분**                 | **AWS**                                                                                        | **GCP**                                                                                  |
| ---------------------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| **가상 네트워크 (VPC)**      | **Amazon VPC**<br><br>  <br><br>• **범위:** 리전(Region) 종속<br>• **서브넷:** 가용 영역(AZ) 단위             | **Cloud VPC**<br><br>  <br><br>• **범위:** 전 세계(Global) 단일 VPC<br>• **서브넷:** 리전(Region) 단위 |
| **로드 밸런서 (L7)**        | **Application Load Balancer (ALB)**<br><br>• 리전별로 IP가 할당됨<br>• 트래픽 급증 시 'Pre-warming' 필요할 수 있음 | **HTTP(S) Load Balancing**<br><br>• 전 세계 단일 Anycast IP 제공<br><br>• 즉각적인 확장성 (별도 워밍업 불필요) |
| **DNS 서비스**            | **Amazon Route 53**<br><br>• 도메인 등록, 트래픽 라우팅, 헬스 체크 등 기능이 매우 강력함                               | **Cloud DNS**<br><br>• 고성능, 프로그래밍 가능한 DNS<br>• 구글 검색과 동일한 인프라 사용                         |
| **전용선 연결 (Hybrid)**    | **AWS Direct Connect**<br><br>• 온프레미스 데이터센터와 AWS를 전용선으로 연결                                     | **Cloud Interconnect**<br><br>• 온프레미스와 구글 클라우드를 연결                                       |
| **CDN (콘텐츠 전송)**       | **Amazon CloudFront**<br><br>  • 엣지 로케이션(Edge Location)이 매우 많음                                 | **Cloud CDN**<br><br>• 로드 밸런서와 통합되어 작동<br><br>• 구글 엣지 캐시 활용                              |
| **VPC 간 연결 (Peering)** | **VPC Peering**<br><br>  • 리전 간 피어링 시 트래픽 비용 발생 및 설정 필요                                        | **VPC Network Peering**<br><br>  • 글로벌 VPC 특성상 리전 간 통신이 더 자연스러움                          |
| **네트워크 허브**            | **Transit Gateway**<br><br>• 중앙 집중식 네트워크 연결 허브<br>• 수많은 VPC와 VPN을 연결할 때 필수                     | **Network Connectivity Center**<br><br>• 단일 관리 모델을 사용하여 연결 관리                            |
| **프라이빗 연결**            | **AWS PrivateLink**<br><br>• 인터넷을 거치지 않고 서비스 간 비공개 연결                                          | **Private Service Connect**<br><br>• VPC 내부 IP로 서비스에 접근                                  |

### Cloud VPC 생성 
| **변수**                   | **값 (입력란)** |
| ------------------------ | ----------- |
| **이름**                   | pista-vpc   |
| **설명**                   |             |
| **서브넷 생성 모드**            |             |
| **MTU**                  | 자동설정        |
| **IPv6 ULA 설정**          |             |
| **(서브넷) 이름**             |             |
| **(서브넷) 리전**             | 도쿄 (asia-northeast1) |
| **(서브넷) IP 스택 유형**       | IPv4        |
| **(서브넷) IPv4 범위**        | 10.0.0.0/24 |
| **(서브넷) 비공개 Google 액세스** | 사용안함        |
| **(서브넷) 흐름 로그**          | 사용안함        |
| **방화벽 규칙**               |             |
| **동적 라우팅 모드**            |             |
| **DNS 구성**               |             |


### 템플릿

![[CloudVPC#**Cloud VPC**]]

---

## GCP 네트워크 구축 가이드

### 1. VPC (Virtual Private Cloud) 구축

#### VPC 특징
| **항목** | **설명** |
|---------|---------|
| **범위** | 글로벌 리소스 (모든 리전에서 사용 가능) |
| **서브넷** | 리전별로 생성 (여러 존에 걸쳐 있음) |
| **라우팅** | 자동 라우팅 테이블 생성 및 관리 |
| **방화벽** | VPC 레벨에서 방화벽 규칙 적용 |

#### VPC 생성 명령어 (gcloud CLI)
```bash
# VPC 생성 (자동 모드)
gcloud compute networks create pista-vpc \
    --subnet-mode=auto \
    --bgp-routing-mode=regional \
    --mtu=1460

# VPC 생성 (커스텀 모드 - 서브넷 수동 생성)
gcloud compute networks create pista-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# VPC 목록 확인
gcloud compute networks list

# VPC 상세 정보 확인
gcloud compute networks describe pista-vpc
```

#### VPC 생성 옵션
| **옵션** | **설명** | **값** |
|---------|---------|--------|
| `--subnet-mode` | 서브넷 생성 모드 | `auto` (자동), `custom` (수동) |
| `--bgp-routing-mode` | 동적 라우팅 모드 | `regional` (리전별), `global` (글로벌) |
| `--mtu` | 최대 전송 단위 | `1460` (기본), `1500` (점보 프레임) |

---

### 2. 서브넷 (Subnet) 구축

#### 서브넷 특징
- **리전 리소스**: 특정 리전에 속하며, 해당 리전의 모든 존에서 사용 가능
- **IP 범위**: RFC 1918 사설 IP 대역 사용 (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- **자동 확장**: 서브넷 IP 범위를 나중에 확장 가능

#### 서브넷 생성 명령어
```bash
# 서브넷 생성
gcloud compute networks subnets create pista-subnet-seoul \
    --network=pista-vpc \
    --region=asia-northeast1 \
    --range=10.0.0.0/24 \
    --enable-private-ip-google-access \
    --enable-flow-logs

# 서브넷 목록 확인
gcloud compute networks subnets list --network=pista-vpc

# 서브넷 상세 정보
gcloud compute networks subnets describe pista-subnet-seoul \
    --region=asia-northeast1
```

#### 서브넷 생성 옵션
| **옵션** | **설명** | **권장값** |
|---------|---------|-----------|
| `--network` | VPC 네트워크 이름 | `pista-vpc` |
| `--region` | 리전 | `asia-northeast1` (도쿄) |
| `--range` | IP CIDR 범위 | `10.0.0.0/24` |
| `--enable-private-ip-google-access` | 비공개 Google 액세스 | 활성화 (내부 IP로 Google API 접근) |
| `--enable-flow-logs` | VPC 흐름 로그 | 필요 시 활성화 (디버깅 용도) |

#### 여러 서브넷 구성 예시
```bash
# Public 서브넷 (웹 서버용)
gcloud compute networks subnets create public-subnet \
    --network=pista-vpc \
    --region=asia-northeast1 \
    --range=10.0.1.0/24

# Private 서브넷 (DB용)
gcloud compute networks subnets create private-subnet \
    --network=pista-vpc \
    --region=asia-northeast1 \
    --range=10.0.2.0/24 \
    --enable-private-ip-google-access
```

---

### 3. Cloud NAT 구축

#### Cloud NAT 특징
| **항목** | **설명** |
|---------|---------|
| **용도** | 외부 IP 없는 VM이 인터넷에 아웃바운드 연결 가능 |
| **관리형 서비스** | Google이 자동으로 관리 (인스턴스 불필요) |
| **고가용성** | 자동으로 중복성 제공 |
| **요금** | NAT Gateway 시간당 요금 + 데이터 처리량 요금 |

#### Cloud Router 생성 (NAT 사전 요구사항)
```bash
# Cloud Router 생성
gcloud compute routers create pista-router \
    --network=pista-vpc \
    --region=asia-northeast1

# Router 목록 확인
gcloud compute routers list
```

#### Cloud NAT 생성 명령어
```bash
# Cloud NAT 생성
gcloud compute routers nats create pista-nat \
    --router=pista-router \
    --region=asia-northeast1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

# NAT 상세 설정 (특정 서브넷만)
gcloud compute routers nats create pista-nat \
    --router=pista-router \
    --region=asia-northeast1 \
    --nat-custom-subnet-ip-ranges=private-subnet \
    --auto-allocate-nat-external-ips

# NAT 목록 확인
gcloud compute routers nats list --router=pista-router \
    --region=asia-northeast1
```

#### Cloud NAT 옵션
| **옵션** | **설명** | **값** |
|---------|---------|--------|
| `--router` | Cloud Router 이름 | `pista-router` |
| `--nat-all-subnet-ip-ranges` | 모든 서브넷에 NAT 적용 | 플래그 설정 |
| `--nat-custom-subnet-ip-ranges` | 특정 서브넷만 NAT 적용 | 서브넷 이름 지정 |
| `--auto-allocate-nat-external-ips` | 외부 IP 자동 할당 | 플래그 설정 |
| `--nat-external-ip-pool` | 수동으로 예약된 IP 사용 | IP 주소 지정 |

---

### 4. 인터넷 게이트웨이 (IGW) 이해

#### GCP IGW의 차이점
| **항목** | **AWS** | **GCP** |
|---------|---------|---------|
| **IGW 리소스** | 명시적으로 생성 및 연결 필요 | **암시적 제공** (별도 생성 불필요) |
| **외부 연결** | IGW를 VPC에 연결해야 함 | 외부 IP가 있으면 자동으로 인터넷 연결 |
| **라우팅** | 라우팅 테이블에 IGW 경로 추가 | 기본 인터넷 게이트웨이 경로 자동 생성 |

#### GCP에서 인터넷 연결 방법

**방법 1: 외부 IP 사용 (IGW 역할)**
```bash
# VM 생성 시 외부 IP 할당
gcloud compute instances create web-server \
    --zone=asia-northeast1-a \
    --subnet=pista-subnet-seoul \
    --network-tier=PREMIUM

# 기존 VM에 외부 IP 추가
gcloud compute instances add-access-config web-server \
    --zone=asia-northeast1-a
```

**방법 2: Cloud NAT 사용 (Private IP만 사용)**
```bash
# 외부 IP 없이 VM 생성
gcloud compute instances create private-server \
    --zone=asia-northeast1-a \
    --subnet=private-subnet \
    --no-address

# Cloud NAT를 통해 아웃바운드 인터넷 연결
```

#### 기본 라우팅 확인
```bash
# VPC 라우팅 테이블 확인
gcloud compute routes list --filter="network=pista-vpc"

# 기본 인터넷 게이트웨이 경로 (자동 생성됨)
# NAME: default-route-xxxx
# DEST_RANGE: 0.0.0.0/0
# NEXT_HOP: default-internet-gateway
```

---

### 5. 방화벽 규칙 설정

#### 기본 방화벽 규칙
```bash
# SSH 허용 (내부 관리용)
gcloud compute firewall-rules create allow-ssh \
    --network=pista-vpc \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow SSH from anywhere"

# HTTP/HTTPS 허용 (웹 서버용)
gcloud compute firewall-rules create allow-http-https \
    --network=pista-vpc \
    --allow=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server

# ICMP 허용 (핑 테스트용)
gcloud compute firewall-rules create allow-icmp \
    --network=pista-vpc \
    --allow=icmp \
    --source-ranges=10.0.0.0/8

# 방화벽 규칙 목록 확인
gcloud compute firewall-rules list --filter="network=pista-vpc"
```

---

### 6. 전체 구축 스크립트 예시

```bash
#!/bin/bash
# GCP VPC 인프라 구축 스크립트

PROJECT_ID="named-foundry-486921-r5"
REGION="asia-northeast1"
ZONE="asia-northeast1-a"

# 프로젝트 설정
gcloud config set project $PROJECT_ID

# 1. VPC 생성
echo "Creating VPC..."
gcloud compute networks create pista-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# 2. 서브넷 생성
echo "Creating subnets..."
gcloud compute networks subnets create public-subnet \
    --network=pista-vpc \
    --region=$REGION \
    --range=10.0.1.0/24

gcloud compute networks subnets create private-subnet \
    --network=pista-vpc \
    --region=$REGION \
    --range=10.0.2.0/24 \
    --enable-private-ip-google-access

# 3. Cloud Router 생성
echo "Creating Cloud Router..."
gcloud compute routers create pista-router \
    --network=pista-vpc \
    --region=$REGION

# 4. Cloud NAT 생성
echo "Creating Cloud NAT..."
gcloud compute routers nats create pista-nat \
    --router=pista-router \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

# 5. 방화벽 규칙 생성
echo "Creating firewall rules..."
gcloud compute firewall-rules create allow-ssh \
    --network=pista-vpc \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0

gcloud compute firewall-rules create allow-http-https \
    --network=pista-vpc \
    --allow=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server

gcloud compute firewall-rules create allow-internal \
    --network=pista-vpc \
    --allow=tcp:0-65535,udp:0-65535,icmp \
    --source-ranges=10.0.0.0/8

echo "VPC infrastructure setup complete!"

# 6. 구성 확인
echo "Verifying setup..."
gcloud compute networks list
gcloud compute networks subnets list --network=pista-vpc
gcloud compute routers list
gcloud compute firewall-rules list --filter="network=pista-vpc"
```

---

### 7. 테스트 및 검증

#### VM 인스턴스 생성으로 테스트
```bash
# Public 서브넷에 웹 서버 생성 (외부 IP 있음)
gcloud compute instances create web-server \
    --zone=$ZONE \
    --subnet=public-subnet \
    --tags=web-server \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install -y nginx
      systemctl start nginx'

# Private 서브넷에 DB 서버 생성 (외부 IP 없음)
gcloud compute instances create db-server \
    --zone=$ZONE \
    --subnet=private-subnet \
    --no-address

# 연결 테스트
# 1. web-server SSH 접속 확인
gcloud compute ssh web-server --zone=$ZONE

# 2. web-server에서 외부 연결 테스트
curl ifconfig.me  # 외부 IP 확인

# 3. db-server SSH 접속 (IAP 터널링 사용)
gcloud compute ssh db-server --zone=$ZONE --tunnel-through-iap

# 4. db-server에서 외부 연결 테스트 (Cloud NAT 통해)
curl ifconfig.me  # NAT IP 확인
```

#### 라우팅 및 연결성 확인
```bash
# 라우팅 테이블 확인
gcloud compute routes list --filter="network=pista-vpc"

# NAT 상태 확인
gcloud compute routers get-status pista-router --region=$REGION

# 방화벽 규칙 적용 확인
gcloud compute firewall-rules describe allow-ssh
```

---

### 8. 주요 차이점 정리 (AWS vs GCP)

| **항목**  | **AWS**                        | **GCP**                  |
| ------- | ------------------------------ | ------------------------ |
| **IGW** | 명시적으로 생성 및 연결 필요               | 암시적 제공 (외부 IP 있으면 자동 연결) |
| **NAT** | NAT Instance 또는 NAT Gateway 생성 | Cloud NAT (관리형 서비스)      |
| **서브넷** | AZ 종속                          | 리전 종속 (여러 존에 걸침)         |
| **라우팅** | 라우팅 테이블 명시적 관리                 | 자동 라우팅 (수동 관리도 가능)       |
| **방화벽** | Security Group + NACL          | VPC 방화벽 규칙 (태그 기반)       |

---

## 구축 스크립트 구현
(2026-02-10)
![[gcp-pista-vpc.png]]

#### 프로젝트 정보
| **항목**         | **값**                     |
| -------------- | ------------------------- |
| **Project ID** | `named-foundry-486921-r5` |
| **Region**     | `asia-northeast1` (도쿄)    |
| **Zone**       | `asia-northeast1-a`       |

#### 구축된 리소스
```
pista-vpc (VPC - Custom Mode)
├── public-subnet  (10.0.1.0/24)
│   └── public-nginx-server
│       ├── External IP: 35.194.98.14
│       ├── Internal IP: 10.0.1.2
│       ├── Machine: e2-micro
│       └── Nginx 설치 (apt install nginx)
│
├── private-subnet (10.0.2.0/24, Private Google Access 활성화)
│   ├── private-nginx-server
│   │   ├── External IP: 없음 (--no-address)
│   │   ├── Internal IP: 10.0.2.2
│   │   ├── Machine: e2-micro
│   │   └── Nginx 설치 (apt install nginx)
│   │
│   └── private-mysql-server
│       ├── External IP: 없음 (--no-address)
│       ├── Internal IP: 10.0.2.x
│       ├── Machine: e2-small
│       ├── MySQL 8.0 설치 (apt install mysql-server)
│       ├── Database: appdb (utf8mb4)
│       └── User: appuser (원격 접속 허용)
│
├── Cloud Router (pista-router)
│   └── Cloud NAT (pista-nat) → Private 아웃바운드 인터넷 연결
│
└── 방화벽 규칙
    ├── allow-ssh-pista-vpc      : tcp:22 (0.0.0.0/0)
    ├── allow-http-pista-vpc     : tcp:80,443 (0.0.0.0/0) → tag:http-server
    ├── allow-internal-pista-vpc : all (10.0.0.0/8)
    └── allow-mysql-pista-vpc    : tcp:3306 (10.0.0.0/8) → tag:mysql-server
```

#### 스크립트 파일
| **파일**                 | **용도**                            | **실행**                      |
| ---------------------- | --------------------------------- | --------------------------- |
| `gcp-vm-setup.sh`      | VPC + 서브넷 + NAT + 방화벽 + VM 생성     | `bash gcp-vm-setup.sh`      |
| `gcp-vm-test.sh`       | Nginx 접속 및 내부 통신 테스트 (Bastion 경유) | `bash gcp-vm-test.sh`       |
| `gcp-vm-cleanup.sh`    | VPC 인프라 리소스 정리 (삭제)               | `bash gcp-vm-cleanup.sh`    |
| `gcp-mysql-setup.sh`   | MySQL VM 인스턴스 + 방화벽 생성            | `bash gcp-mysql-setup.sh`   |
| `gcp-mysql-test.sh`    | MySQL 접속 및 서비스 상태 테스트             | `bash gcp-mysql-test.sh`    |
| `gcp-mysql-cleanup.sh` | MySQL VM + 방화벽 리소스 정리 (삭제)        | `bash gcp-mysql-cleanup.sh` |

#### 구축 프로세스 (gcp-vm-setup.sh 8단계)
```
[1/8] VPC 생성 (pista-vpc, Custom Mode)
[2/8] Public 서브넷 생성 (10.0.1.0/24)
[3/8] Private 서브넷 생성 (10.0.2.0/24)
[4/8] Cloud Router 생성
[5/8] Cloud NAT 생성 (Private 아웃바운드용)
[6/8] 방화벽 규칙 생성 (SSH, HTTP, 내부통신)
[7/8] Public 인스턴스 생성 + Nginx 설치
[8/8] Private 인스턴스 생성 + Nginx 설치
```

#### MySQL 구축 프로세스 (gcp-mysql-setup.sh 2단계)
```
[1/2] MySQL 방화벽 규칙 생성 (tcp:3306, 내부 네트워크)
[2/2] MySQL VM 인스턴스 생성 + MySQL 8.0 설치 및 설정
```

#### 테스트 방법 (gcp-vm-test.sh 4단계)
```
[1/4] Public 서버 외부 접속 (curl http://35.194.98.14)
[2/4] Public 서버 Nginx 상태 확인 (systemctl status)
[3/4] Public → Private 내부 통신 (curl http://10.0.2.2)
[4/4] Private 서버 NAT 테스트 (Public Bastion 경유)
```

#### MySQL 테스트 방법 (gcp-mysql-test.sh 3단계)
```
[1/3] MySQL 인스턴스 상태 확인 (gcloud describe)
[2/3] MySQL 서비스 상태 확인 (Bastion 경유)
[3/3] MySQL 접속 테스트 (Bastion 경유, SHOW DATABASES)
```

#### Private 서버 접속 방법 (Bastion 경유)
```bash
# IAP 권한이 없는 경우 Public 서버를 Bastion으로 사용
gcloud compute ssh public-nginx-server --zone=asia-northeast1-a

# Public 서버 안에서 Private 서버로 SSH
ssh 10.0.2.2

# Public 서버 안에서 MySQL 접속 테스트
mysql -h <MYSQL_PRIVATE_IP> -u appuser -pAppUser456! appdb
```

#### 리소스 정리 (gcp-vm-cleanup.sh 6단계)
```
[1/6] VM 인스턴스 삭제 (public-nginx, private-nginx)
[2/6] 방화벽 규칙 삭제 (SSH, HTTP, 내부통신)
[3/6] Cloud NAT 삭제
[4/6] Cloud Router 삭제
[5/6] 서브넷 삭제
[6/6] VPC 삭제
```

#### MySQL 리소스 정리 (gcp-mysql-cleanup.sh 2단계)
```
[1/2] MySQL VM 인스턴스 삭제 (private-mysql-server)
[2/2] MySQL 방화벽 규칙 삭제 (allow-mysql-pista-vpc)
```

---

## Compute Engine - VM 인스턴스

### 1. VM 인스턴스 개요

#### Compute Engine 특징
| **항목** | **설명** |
|---------|---------|
| **리소스 종류** | 존(Zone) 리소스 (특정 존에 생성) |
| **운영체제** | Linux, Windows, Container-Optimized OS 등 |
| **머신 타입** | 범용, 컴퓨팅 최적화, 메모리 최적화, GPU 등 |
| **디스크** | 영구 디스크(PD), 로컬 SSD, 부팅 디스크 |
| **네트워킹** | VPC, 서브넷, 외부/내부 IP, 방화벽 규칙 |
| **비용 절감** | 지속 사용 할인, 약정 사용 할인, 선점형 VM |

---

### 2. 머신 타입 (Machine Types)

#### 머신 패밀리 비교
| **패밀리** | **용도** | **머신 시리즈** | **특징** |
|---------|---------|--------------|---------|
| **범용 (E2)** | 일반 워크로드 | `e2-standard`, `e2-highmem`, `e2-highcpu` | 비용 효율적, 일반적인 애플리케이션 |
| **범용 (N1)** | 균형잡힌 워크로드 | `n1-standard`, `n1-highmem`, `n1-highcpu` | 안정적, 다양한 워크로드 |
| **범용 (N2/N2D)** | 향상된 성능 | `n2-standard`, `n2d-standard` | 최신 CPU, 높은 성능 |
| **컴퓨팅 최적화 (C2)** | CPU 집약적 워크로드 | `c2-standard` | 고성능 컴퓨팅, 게임 서버 |
| **메모리 최적화 (M2)** | 메모리 집약적 워크로드 | `m2-ultramem`, `m2-megamem` | 대용량 인메모리 데이터베이스 |

#### 머신 타입 네이밍 규칙
```
<시리즈>-<워크로드-유형>-<vCPU-수>

예시:
- n2-standard-4    : N2 시리즈, 표준 (4 vCPU, 16GB RAM)
- e2-highmem-8     : E2 시리즈, 고메모리 (8 vCPU, 64GB RAM)
- c2-standard-16   : C2 시리즈, 표준 (16 vCPU, 64GB RAM)
```

#### 머신 타입 조회
```bash
# 특정 존의 머신 타입 목록
gcloud compute machine-types list --zones=asia-northeast1-a

# 특정 시리즈 필터링
gcloud compute machine-types list \
    --zones=asia-northeast1-a \
    --filter="name:n2-standard*"

# 머신 타입 상세 정보
gcloud compute machine-types describe n2-standard-4 \
    --zone=asia-northeast1-a
```

---

### 3. VM 인스턴스 생성

#### 기본 VM 생성
```bash
# 간단한 VM 생성
gcloud compute instances create my-vm \
    --zone=asia-northeast1-a \
    --machine-type=e2-medium

# 상세 옵션 VM 생성
gcloud compute instances create web-server \
    --zone=asia-northeast1-a \
    --machine-type=n2-standard-4 \
    --subnet=public-subnet \
    --network-tier=PREMIUM \
    --maintenance-policy=MIGRATE \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=50GB \
    --boot-disk-type=pd-balanced \
    --boot-disk-device-name=web-server-boot \
    --tags=web-server,http-server \
    --labels=environment=production,team=backend \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install -y nginx
      systemctl start nginx
      echo "Hello from $(hostname)" > /var/www/html/index.html'
```

#### VM 생성 주요 옵션
| **옵션** | **설명** | **예시 값** |
|---------|---------|-----------|
| `--zone` | VM을 생성할 존 | `asia-northeast1-a` (서울) |
| `--machine-type` | 머신 타입 | `n2-standard-4`, `e2-medium` |
| `--subnet` | 서브넷 지정 | `public-subnet` |
| `--network-tier` | 네트워크 티어 | `PREMIUM` (기본), `STANDARD` |
| `--image-family` | OS 이미지 패밀리 | `ubuntu-2204-lts`, `debian-11` |
| `--image-project` | 이미지 프로젝트 | `ubuntu-os-cloud`, `debian-cloud` |
| `--boot-disk-size` | 부팅 디스크 크기 | `50GB`, `100GB` |
| `--boot-disk-type` | 디스크 유형 | `pd-balanced`, `pd-ssd`, `pd-standard` |
| `--tags` | 네트워크 태그 (방화벽 규칙 적용) | `web-server`, `database` |
| `--labels` | 라벨 (리소스 관리용) | `env=prod`, `team=backend` |
| `--metadata` | 메타데이터 (스타트업 스크립트 등) | `startup-script=...` |
| `--no-address` | 외부 IP 할당 안 함 | 플래그 설정 |
| `--address` | 고정 외부 IP 지정 | 예약된 IP 주소 |
| `--preemptible` | 선점형 VM (저렴, 최대 24시간) | 플래그 설정 |
| `--spot` | Spot VM (선점형 개선 버전) | 플래그 설정 |

#### 커스텀 머신 타입 생성
```bash
# 커스텀 CPU와 메모리 지정 (vCPU 4개, RAM 8GB)
gcloud compute instances create custom-vm \
    --zone=asia-northeast1-a \
    --custom-cpu=4 \
    --custom-memory=8GB

# 확장 메모리 커스텀 머신 (vCPU당 최대 8GB 메모리)
gcloud compute instances create custom-highmem-vm \
    --zone=asia-northeast1-a \
    --custom-cpu=4 \
    --custom-memory=32GB \
    --custom-extensions
```

---

### 4. 디스크 관리

#### 디스크 유형
| **디스크 유형** | **IOPS/GB** | **처리량** | **용도** | **비용** |
|--------------|-----------|----------|---------|---------|
| `pd-standard` | 낮음 | 낮음 | 백업, 아카이브 | 가장 저렴 |
| `pd-balanced` | 중간 | 중간 | 일반 워크로드 (권장) | 중간 |
| `pd-ssd` | 높음 | 높음 | 데이터베이스, 고성능 앱 | 비싸다 |
| `pd-extreme` | 매우 높음 | 매우 높음 | SAP HANA, Oracle | 가장 비싸다 |
| `local-ssd` | 최고 | 최고 | 임시 데이터, 캐시 | vCPU당 요금 |

#### 영구 디스크 생성 및 연결
```bash
# 영구 디스크 생성
gcloud compute disks create data-disk \
    --size=100GB \
    --type=pd-balanced \
    --zone=asia-northeast1-a

# 기존 VM에 디스크 연결
gcloud compute instances attach-disk web-server \
    --disk=data-disk \
    --zone=asia-northeast1-a

# VM 내부에서 디스크 포맷 및 마운트
# SSH로 접속 후:
sudo mkfs.ext4 -F /dev/sdb
sudo mkdir -p /mnt/data
sudo mount /dev/sdb /mnt/data
echo '/dev/sdb /mnt/data ext4 defaults 0 0' | sudo tee -a /etc/fstab

# 디스크 분리
gcloud compute instances detach-disk web-server \
    --disk=data-disk \
    --zone=asia-northeast1-a
```

#### 디스크 크기 조정 (확장만 가능)
```bash
# 디스크 크기 확장 (100GB -> 200GB)
gcloud compute disks resize data-disk \
    --size=200GB \
    --zone=asia-northeast1-a

# VM 내부에서 파일시스템 확장
sudo resize2fs /dev/sdb
```

#### 로컬 SSD 추가
```bash
# VM 생성 시 로컬 SSD 추가 (최대 24개, 각 375GB)
gcloud compute instances create vm-with-ssd \
    --zone=asia-northeast1-a \
    --machine-type=n2-standard-4 \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME
```

---

### 5. 네트워크 인터페이스

#### 다중 네트워크 인터페이스
```bash
# 여러 네트워크 인터페이스를 가진 VM 생성
gcloud compute instances create multi-nic-vm \
    --zone=asia-northeast1-a \
    --machine-type=n2-standard-4 \
    --network-interface=subnet=public-subnet \
    --network-interface=subnet=private-subnet,no-address
```

#### 외부 IP 관리
```bash
# 고정 외부 IP 예약
gcloud compute addresses create web-server-ip \
    --region=asia-northeast1

# 예약된 IP로 VM 생성
gcloud compute instances create web-server \
    --zone=asia-northeast1-a \
    --address=web-server-ip

# 기존 VM에 외부 IP 추가
gcloud compute instances add-access-config web-server \
    --zone=asia-northeast1-a \
    --access-config-name="External NAT"

# 외부 IP 제거
gcloud compute instances delete-access-config web-server \
    --zone=asia-northeast1-a \
    --access-config-name="External NAT"

# IP 주소 목록 확인
gcloud compute addresses list
```

#### 내부 DNS 및 호스트명
```bash
# 커스텀 호스트명 설정
gcloud compute instances create web-server \
    --zone=asia-northeast1-a \
    --hostname=web.example.com

# 내부 DNS 이름으로 접근 (같은 VPC 내에서)
# <인스턴스-이름>.<존>.<프로젝트-ID>.internal
# 예: web-server.asia-northeast1-a.c.my-project.internal
```

---

### 6. VM 관리 명령어

#### 인스턴스 목록 및 상태
```bash
# 모든 VM 인스턴스 목록
gcloud compute instances list

# 특정 존의 VM 목록
gcloud compute instances list --zones=asia-northeast1-a

# 특정 VM 상세 정보
gcloud compute instances describe web-server \
    --zone=asia-northeast1-a

# VM 상태만 확인
gcloud compute instances describe web-server \
    --zone=asia-northeast1-a \
    --format="value(status)"
```

#### VM 시작/중지/재시작
```bash
# VM 중지 (과금 중단, 디스크는 유지)
gcloud compute instances stop web-server \
    --zone=asia-northeast1-a

# VM 시작
gcloud compute instances start web-server \
    --zone=asia-northeast1-a

# VM 재시작 (OS 재부팅)
gcloud compute instances reset web-server \
    --zone=asia-northeast1-a

# 여러 VM 동시 작업
gcloud compute instances stop web-server-1 web-server-2 \
    --zone=asia-northeast1-a
```

#### VM 삭제
```bash
# VM 삭제 (디스크도 함께 삭제)
gcloud compute instances delete web-server \
    --zone=asia-northeast1-a

# VM 삭제 (디스크 보존)
gcloud compute instances delete web-server \
    --zone=asia-northeast1-a \
    --keep-disks=all

# 부팅 디스크만 보존
gcloud compute instances delete web-server \
    --zone=asia-northeast1-a \
    --keep-disks=boot
```

#### VM 메타데이터 수정
```bash
# 메타데이터 추가/수정
gcloud compute instances add-metadata web-server \
    --zone=asia-northeast1-a \
    --metadata=key1=value1,key2=value2

# 메타데이터 제거
gcloud compute instances remove-metadata web-server \
    --zone=asia-northeast1-a \
    --keys=key1,key2

# 스타트업 스크립트 업데이트
gcloud compute instances add-metadata web-server \
    --zone=asia-northeast1-a \
    --metadata-from-file=startup-script=startup.sh
```

#### 라벨 관리
```bash
# 라벨 추가/수정
gcloud compute instances update web-server \
    --zone=asia-northeast1-a \
    --update-labels=environment=production,team=backend

# 라벨 제거
gcloud compute instances update web-server \
    --zone=asia-northeast1-a \
    --remove-labels=team
```

---

### 7. SSH 접속 방법

#### gcloud SSH 접속
```bash
# 기본 SSH 접속
gcloud compute ssh web-server --zone=asia-northeast1-a

# 특정 사용자로 접속
gcloud compute ssh myuser@web-server --zone=asia-northeast1-a

# 커스텀 SSH 키 사용
gcloud compute ssh web-server \
    --zone=asia-northeast1-a \
    --ssh-key-file=~/.ssh/my-key

# IAP 터널링 사용 (외부 IP 없는 VM)
gcloud compute ssh web-server \
    --zone=asia-northeast1-a \
    --tunnel-through-iap

# SSH 명령어 직접 실행
gcloud compute ssh web-server \
    --zone=asia-northeast1-a \
    --command="sudo systemctl status nginx"
```

#### SCP 파일 전송
```bash
# 로컬 -> VM
gcloud compute scp local-file.txt web-server:/tmp/ \
    --zone=asia-northeast1-a

# VM -> 로컬
gcloud compute scp web-server:/tmp/remote-file.txt ./ \
    --zone=asia-northeast1-a

# 디렉토리 전송 (재귀)
gcloud compute scp --recurse ./local-dir web-server:/tmp/ \
    --zone=asia-northeast1-a
```

#### IAP (Identity-Aware Proxy) 설정
```bash
# IAP용 방화벽 규칙 생성
gcloud compute firewall-rules create allow-iap-ssh \
    --network=pista-vpc \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --description="Allow SSH from IAP"

# IAP 터널링으로 SSH 접속
gcloud compute ssh private-server \
    --zone=asia-northeast1-a \
    --tunnel-through-iap
```

---

### 8. 인스턴스 템플릿

#### 템플릿 생성
```bash
# 인스턴스 템플릿 생성
gcloud compute instance-templates create web-server-template \
    --machine-type=n2-standard-2 \
    --subnet=public-subnet \
    --region=asia-northeast1 \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-balanced \
    --tags=web-server,http-server \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install -y nginx
      systemctl start nginx'

# 템플릿 목록 확인
gcloud compute instance-templates list

# 템플릿 상세 정보
gcloud compute instance-templates describe web-server-template
```

#### 템플릿에서 VM 생성
```bash
# 템플릿으로 VM 인스턴스 생성
gcloud compute instances create web-server-1 \
    --source-instance-template=web-server-template \
    --zone=asia-northeast1-a

# 템플릿 옵션 오버라이드
gcloud compute instances create web-server-2 \
    --source-instance-template=web-server-template \
    --zone=asia-northeast1-b \
    --machine-type=n2-standard-4
```

---

### 9. 관리형 인스턴스 그룹 (MIG)

#### 관리형 인스턴스 그룹 특징
| **항목** | **설명** |
|---------|---------|
| **자동 확장** | CPU, 메모리 사용률 기반 자동 스케일링 |
| **자동 복구** | 비정상 인스턴스 자동 재생성 |
| **로드 밸런싱** | 자동으로 로드 밸런서와 통합 |
| **롤링 업데이트** | 무중단 배포 지원 |
| **리전/존 MIG** | 리전 MIG는 여러 존에 분산 (고가용성) |

#### 리전 MIG 생성 (권장)
```bash
# 리전 관리형 인스턴스 그룹 생성
gcloud compute instance-groups managed create web-server-mig \
    --base-instance-name=web-server \
    --template=web-server-template \
    --size=3 \
    --region=asia-northeast1 \
    --target-distribution-shape=EVEN

# 자동 확장 설정
gcloud compute instance-groups managed set-autoscaling web-server-mig \
    --region=asia-northeast1 \
    --min-num-replicas=2 \
    --max-num-replicas=10 \
    --target-cpu-utilization=0.75 \
    --cool-down-period=60

# 자동 복구 설정 (헬스 체크 기반)
gcloud compute health-checks create http web-health-check \
    --port=80 \
    --request-path=/ \
    --check-interval=10s \
    --timeout=5s \
    --unhealthy-threshold=3 \
    --healthy-threshold=2

gcloud compute instance-groups managed update web-server-mig \
    --region=asia-northeast1 \
    --health-check=web-health-check \
    --initial-delay=300
```

#### 존 MIG 생성
```bash
# 존 관리형 인스턴스 그룹 생성
gcloud compute instance-groups managed create web-server-mig-zone \
    --base-instance-name=web-server \
    --template=web-server-template \
    --size=3 \
    --zone=asia-northeast1-a
```

#### MIG 관리 명령어
```bash
# MIG 목록
gcloud compute instance-groups managed list

# MIG 크기 수동 조정
gcloud compute instance-groups managed resize web-server-mig \
    --region=asia-northeast1 \
    --size=5

# 롤링 업데이트 (새 템플릿 적용)
gcloud compute instance-groups managed rolling-action start-update web-server-mig \
    --region=asia-northeast1 \
    --version=template=web-server-template-v2 \
    --max-surge=3 \
    --max-unavailable=0

# MIG 인스턴스 목록
gcloud compute instance-groups managed list-instances web-server-mig \
    --region=asia-northeast1
```

---

### 10. 스냅샷 및 이미지

#### 디스크 스냅샷
```bash
# 스냅샷 생성 (증분 백업)
gcloud compute disks snapshot web-server-boot \
    --zone=asia-northeast1-a \
    --snapshot-names=web-server-snapshot-$(date +%Y%m%d)

# 스냅샷 목록
gcloud compute snapshots list

# 스냅샷에서 디스크 복원
gcloud compute disks create restored-disk \
    --source-snapshot=web-server-snapshot-20260210 \
    --zone=asia-northeast1-a

# 스냅샷 삭제
gcloud compute snapshots delete web-server-snapshot-20260210
```

#### 커스텀 이미지
```bash
# 실행 중인 VM에서 이미지 생성
gcloud compute images create web-server-image-v1 \
    --source-disk=web-server-boot \
    --source-disk-zone=asia-northeast1-a \
    --family=web-server-images

# 이미지 목록
gcloud compute images list --no-standard-images

# 커스텀 이미지로 VM 생성
gcloud compute instances create web-server-clone \
    --zone=asia-northeast1-a \
    --image=web-server-image-v1

# 이미지 삭제
gcloud compute images delete web-server-image-v1
```

---

### 11. 메타데이터 및 서비스 계정

#### VM 메타데이터 서버
```bash
# VM 내부에서 메타데이터 조회
curl -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/

# 인스턴스 정보
curl -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/name

# 프로젝트 정보
curl -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/project/project-id

# 액세스 토큰 (서비스 계정)
curl -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token
```

#### 서비스 계정 설정
```bash
# 커스텀 서비스 계정으로 VM 생성
gcloud compute instances create web-server \
    --zone=asia-northeast1-a \
    --service-account=my-service-account@project-id.iam.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform

# 기존 VM의 서비스 계정 변경 (중지 상태에서만 가능)
gcloud compute instances stop web-server --zone=asia-northeast1-a
gcloud compute instances set-service-account web-server \
    --zone=asia-northeast1-a \
    --service-account=new-account@project-id.iam.gserviceaccount.com \
    --scopes=cloud-platform
gcloud compute instances start web-server --zone=asia-northeast1-a
```

---

### 12. 비용 최적화

#### 선점형 VM (Preemptible VM)
```bash
# 선점형 VM 생성 (일반 VM 대비 60-91% 저렴)
gcloud compute instances create preemptible-vm \
    --zone=asia-northeast1-a \
    --machine-type=n2-standard-4 \
    --preemptible

# 주의사항:
# - 최대 24시간 실행
# - Google이 필요 시 언제든 종료 가능
# - SLA 없음
# - 배치 작업, 테스트 환경에 적합
```

#### Spot VM (개선된 선점형 VM)
```bash
# Spot VM 생성
gcloud compute instances create spot-vm \
    --zone=asia-northeast1-a \
    --machine-type=n2-standard-4 \
    --provisioning-model=SPOT \
    --instance-termination-action=STOP

# Spot VM 특징:
# - 선점형 VM과 동일한 가격
# - 24시간 제한 없음
# - 종료 시 동작 선택 가능 (STOP, DELETE)
```

#### 약정 사용 할인 (CUD - Committed Use Discounts)
```bash
# 약정 구매 (1년 또는 3년)
gcloud compute commitments create my-commitment \
    --region=asia-northeast1 \
    --plan=12-month \
    --resources=vcpu=100,memory=400GB

# 약정 목록 확인
gcloud compute commitments list
```

#### 지속 사용 할인 (자동 적용)
- 매월 특정 리소스를 25% 이상 사용 시 자동 할인
- 별도 설정 불필요
- 최대 30% 할인

#### VM 크기 조정 (Resize)
```bash
# VM 중지 후 머신 타입 변경
gcloud compute instances stop web-server --zone=asia-northeast1-a

gcloud compute instances set-machine-type web-server \
    --zone=asia-northeast1-a \
    --machine-type=n2-standard-8

gcloud compute instances start web-server --zone=asia-northeast1-a
```

---

### 13. 모니터링 및 로깅

#### Cloud Monitoring 메트릭
```bash
# VM CPU 사용률 확인 (gcloud 명령어로는 제한적)
# Cloud Console에서 확인 권장

# 직렬 포트 출력 (부팅 로그 확인)
gcloud compute instances get-serial-port-output web-server \
    --zone=asia-northeast1-a
```

#### 로그 확인
```bash
# VM 관련 로그 확인 (Cloud Logging)
gcloud logging read "resource.type=gce_instance AND \
    resource.labels.instance_id=<INSTANCE_ID>" \
    --limit=50 \
    --format=json
```

---

### 14. VM 인스턴스 전체 관리 스크립트

```bash
#!/bin/bash
# VM 인스턴스 생성 및 관리 자동화 스크립트

PROJECT_ID="named-foundry-486921-r5"
REGION="asia-northeast1"
ZONE="asia-northeast1-a"
VPC_NAME="pista-vpc"
SUBNET_NAME="public-subnet"

# 1. 인스턴스 템플릿 생성
echo "Creating instance template..."
gcloud compute instance-templates create web-template \
    --machine-type=n2-standard-2 \
    --subnet=$SUBNET_NAME \
    --region=$REGION \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-balanced \
    --tags=web-server,http-server \
    --metadata=startup-script='#!/bin/bash
      apt-get update && apt-get install -y nginx
      systemctl start nginx
      echo "Hello from $(hostname)" > /var/www/html/index.html'

# 2. 헬스 체크 생성
echo "Creating health check..."
gcloud compute health-checks create http web-health-check \
    --port=80 \
    --request-path=/ \
    --check-interval=10s \
    --timeout=5s

# 3. 리전 MIG 생성
echo "Creating managed instance group..."
gcloud compute instance-groups managed create web-mig \
    --base-instance-name=web \
    --template=web-template \
    --size=2 \
    --region=$REGION \
    --health-check=web-health-check \
    --initial-delay=300

# 4. 자동 확장 설정
echo "Setting up autoscaling..."
gcloud compute instance-groups managed set-autoscaling web-mig \
    --region=$REGION \
    --min-num-replicas=2 \
    --max-num-replicas=5 \
    --target-cpu-utilization=0.75 \
    --cool-down-period=60

echo "VM infrastructure setup complete!"

# 5. 상태 확인
gcloud compute instance-groups managed list
gcloud compute instance-groups managed list-instances web-mig \
    --region=$REGION
```

---

## Cloud SQL - 관리형 데이터베이스

### 1. Cloud SQL 개요

#### Cloud SQL 특징
| **항목** | **설명** |
|---------|---------|
| **서비스 유형** | 완전 관리형 관계형 데이터베이스 서비스 |
| **지원 DB 엔진** | MySQL, PostgreSQL, SQL Server |
| **자동 백업** | 일일 자동 백업 + 트랜잭션 로그 백업 |
| **고가용성** | 리전 내 자동 장애 조치 (Regional HA) |
| **자동 패치** | Google이 DB 엔진 패치 및 OS 업데이트 관리 |
| **암호화** | 저장 데이터 및 전송 데이터 자동 암호화 |
| **확장성** | 수직 확장 (머신 타입 변경) + 읽기 전용 복제본 |
| **최대 스토리지** | 64TB (MySQL/PostgreSQL) |
| **SLA** | 99.95% (HA 구성 시) |

#### VM MySQL vs Cloud SQL 비교
| **항목** | **VM에 직접 설치** | **Cloud SQL** |
|---------|------------------|--------------|
| **설치/설정** | 수동 (apt install, my.cnf 설정) | gcloud 명령어 한 줄로 생성 |
| **백업** | 수동 (mysqldump, cron 설정) | 자동 백업 + 온디맨드 백업 |
| **패치/업데이트** | 수동 (apt upgrade) | Google이 자동 관리 |
| **HA/장애 조치** | 수동 구성 (Replication + Failover) | 체크박스 하나로 HA 활성화 |
| **모니터링** | 수동 (Prometheus, Grafana 등) | Cloud Monitoring 자동 통합 |
| **보안** | 수동 (SSL 설정, 방화벽 관리) | 자동 암호화, IAM 통합 |
| **비용** | VM 비용만 (저렴하지만 관리 비용 높음) | 관리형 서비스 비용 (높지만 운영 비용 절감) |
| **적합한 경우** | 세밀한 제어 필요, 비용 최소화 | 운영 부담 최소화, 프로덕션 환경 |

#### AWS RDS vs Cloud SQL 비교
| **항목** | **AWS RDS** | **Cloud SQL** |
|---------|------------|--------------|
| **지원 엔진** | MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, Aurora | MySQL, PostgreSQL, SQL Server |
| **HA 방식** | Multi-AZ (다른 AZ에 스탠바이) | Regional HA (같은 리전 내 다른 존) |
| **읽기 복제본** | 리전 내 + 크로스 리전 | 리전 내 + 크로스 리전 |
| **자동 백업** | 최대 35일 보관 | 최대 365일 보관 |
| **연결 프록시** | RDS Proxy | Cloud SQL Auth Proxy |
| **Private 연결** | VPC 내 서브넷 그룹 | VPC 피어링 또는 Private Service Connect |
| **서버리스 옵션** | Aurora Serverless | Cloud SQL 없음 (AlloyDB 또는 Spanner 사용) |

---

### 2. Cloud SQL 인스턴스 생성

#### MySQL 인스턴스 생성
```bash
# MySQL 8.0 인스턴스 생성 (기본)
gcloud sql instances create my-mysql \
    --database-version=MYSQL_8_0 \
    --tier=db-n1-standard-2 \
    --region=asia-northeast1 \
    --storage-size=20GB \
    --storage-type=SSD \
    --storage-auto-increase

# MySQL 인스턴스 생성 (상세 옵션)
gcloud sql instances create my-mysql \
    --database-version=MYSQL_8_0 \
    --tier=db-custom-4-16384 \
    --region=asia-northeast1 \
    --storage-size=50GB \
    --storage-type=SSD \
    --storage-auto-increase \
    --backup-start-time=03:00 \
    --enable-bin-log \
    --maintenance-window-day=SUN \
    --maintenance-window-hour=2 \
    --availability-type=REGIONAL \
    --root-password=<ROOT_PASSWORD>
```

#### PostgreSQL 인스턴스 생성
```bash
# PostgreSQL 15 인스턴스 생성
gcloud sql instances create my-postgres \
    --database-version=POSTGRES_15 \
    --tier=db-custom-4-16384 \
    --region=asia-northeast1 \
    --storage-size=50GB \
    --storage-type=SSD \
    --storage-auto-increase \
    --backup-start-time=03:00 \
    --availability-type=REGIONAL
```

#### 인스턴스 생성 옵션
| **옵션** | **설명** | **값** |
|---------|---------|--------|
| `--database-version` | DB 엔진 버전 | `MYSQL_8_0`, `MYSQL_5_7`, `POSTGRES_15`, `POSTGRES_14`, `SQLSERVER_2019_STANDARD` |
| `--tier` | 머신 타입 | `db-n1-standard-1`, `db-custom-<CPU>-<RAM_MB>` |
| `--region` | 리전 | `asia-northeast1` (도쿄) |
| `--storage-size` | 스토리지 크기 | `10GB` ~ `64TB` |
| `--storage-type` | 스토리지 유형 | `SSD` (기본), `HDD` |
| `--storage-auto-increase` | 스토리지 자동 확장 | 플래그 설정 |
| `--storage-auto-increase-limit` | 자동 확장 최대 크기 | `0` (무제한), 또는 GB 단위 |
| `--backup-start-time` | 자동 백업 시작 시간 (UTC) | `03:00` (한국시간 12:00) |
| `--enable-bin-log` | 바이너리 로그 활성화 (MySQL PITR용) | 플래그 설정 |
| `--availability-type` | 가용성 타입 | `ZONAL` (단일 존), `REGIONAL` (HA) |
| `--root-password` | 루트 비밀번호 | 비밀번호 문자열 |
| `--maintenance-window-day` | 유지보수 요일 | `MON`~`SUN` |
| `--maintenance-window-hour` | 유지보수 시간 (UTC) | `0`~`23` |

#### Private IP로 인스턴스 생성 (VPC 피어링)
```bash
# 1. Private Service Access 설정 (최초 1회)
# IP 범위 할당
gcloud compute addresses create google-managed-services \
    --global \
    --purpose=VPC_PEERING \
    --prefix-length=16 \
    --network=pista-vpc

# VPC 피어링 생성
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services \
    --network=pista-vpc

# 2. Private IP로 Cloud SQL 인스턴스 생성
gcloud sql instances create my-mysql-private \
    --database-version=MYSQL_8_0 \
    --tier=db-n1-standard-2 \
    --region=asia-northeast1 \
    --network=pista-vpc \
    --no-assign-ip \
    --storage-size=20GB \
    --storage-type=SSD
```

---

### 3. 데이터베이스 및 사용자 관리

#### 데이터베이스 관리
```bash
# 데이터베이스 생성
gcloud sql databases create mydb \
    --instance=my-mysql \
    --charset=utf8mb4 \
    --collation=utf8mb4_unicode_ci

# 데이터베이스 목록
gcloud sql databases list --instance=my-mysql

# 데이터베이스 삭제
gcloud sql databases delete mydb --instance=my-mysql
```

#### 사용자 관리
```bash
# 사용자 생성
gcloud sql users create myuser \
    --instance=my-mysql \
    --password=<PASSWORD> \
    --host=%

# 사용자 목록
gcloud sql users list --instance=my-mysql

# 비밀번호 변경
gcloud sql users set-password myuser \
    --instance=my-mysql \
    --password=<NEW_PASSWORD> \
    --host=%

# 사용자 삭제
gcloud sql users delete myuser \
    --instance=my-mysql \
    --host=%
```

---

### 4. 연결 방법

#### Cloud SQL Auth Proxy (권장)
```bash
# 1. Cloud SQL Auth Proxy 설치 (macOS)
curl -o cloud-sql-proxy \
    https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.1/cloud-sql-proxy.darwin.amd64
chmod +x cloud-sql-proxy

# 1. Cloud SQL Auth Proxy 설치 (Linux)
curl -o cloud-sql-proxy \
    https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.1/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy

# 2. Proxy 실행 (인스턴스 연결 이름 사용)
./cloud-sql-proxy <PROJECT_ID>:asia-northeast1:my-mysql \
    --port=3306

# 3. 다른 터미널에서 MySQL 접속
mysql -u myuser -p --host=127.0.0.1 --port=3306

# 인스턴스 연결 이름 확인
gcloud sql instances describe my-mysql \
    --format="value(connectionName)"
```

#### Private IP 연결 (같은 VPC 내 VM에서)
```bash
# VM에서 Cloud SQL Private IP로 직접 연결
# (Cloud SQL이 Private IP로 생성된 경우)

# Private IP 확인
gcloud sql instances describe my-mysql-private \
    --format="value(ipAddresses.ipAddress)"

# VM에서 MySQL 접속
mysql -u myuser -p --host=<PRIVATE_IP> --port=3306
```

#### Public IP + 승인된 네트워크
```bash
# 승인된 네트워크 추가 (특정 IP에서만 접속 허용)
gcloud sql instances patch my-mysql \
    --authorized-networks=203.0.113.0/24,198.51.100.0/32

# Public IP 확인
gcloud sql instances describe my-mysql \
    --format="value(ipAddresses[0].ipAddress)"

# 외부에서 MySQL 접속
mysql -u myuser -p --host=<PUBLIC_IP> --port=3306
```

#### 연결 방법 비교
| **방법** | **보안** | **설정 난이도** | **지연시간** | **적합한 경우** |
|---------|---------|--------------|-----------|--------------|
| **Cloud SQL Auth Proxy** | 높음 (IAM 인증, SSL 자동) | 중간 | 약간 추가 | 개발/운영 범용 (권장) |
| **Private IP** | 높음 (VPC 내부 통신) | 높음 (VPC 피어링 필요) | 최소 | 프로덕션 (같은 VPC 내 VM/GKE) |
| **Public IP + 승인 네트워크** | 중간 (IP 화이트리스트) | 낮음 | 중간 | 개발/테스트 (임시 접속) |

---

### 5. 백업 및 복원

#### 자동 백업 설정
```bash
# 자동 백업 활성화 (UTC 기준 시간 설정)
gcloud sql instances patch my-mysql \
    --backup-start-time=03:00

# 자동 백업 보관 기간 설정
gcloud sql instances patch my-mysql \
    --retained-backups-count=30 \
    --enable-bin-log

# 자동 백업 비활성화
gcloud sql instances patch my-mysql \
    --no-backup
```

#### 수동 백업 (온디맨드)
```bash
# 수동 백업 생성
gcloud sql backups create \
    --instance=my-mysql \
    --description="배포 전 수동 백업"

# 백업 목록 확인
gcloud sql backups list --instance=my-mysql

# 백업 상세 정보
gcloud sql backups describe <BACKUP_ID> \
    --instance=my-mysql
```

#### 백업에서 복원
```bash
# 같은 인스턴스로 복원 (기존 데이터 덮어쓰기)
gcloud sql backups restore <BACKUP_ID> \
    --restore-instance=my-mysql

# 다른 인스턴스로 복원 (새 인스턴스 생성)
gcloud sql instances clone my-mysql my-mysql-restored \
    --point-in-time=<BACKUP_TIMESTAMP>
```

#### PITR (Point-in-Time Recovery)
```bash
# 바이너리 로그 활성화 (PITR 전제 조건)
gcloud sql instances patch my-mysql \
    --enable-bin-log

# 특정 시점으로 복원 (새 인스턴스로 클론)
gcloud sql instances clone my-mysql my-mysql-pitr \
    --point-in-time="2026-02-10T03:00:00.000Z"
```

---

### 6. 고가용성 (HA)

#### HA 특징
| **항목** | **설명** |
|---------|---------|
| **구성** | 프라이머리 + 스탠바이 인스턴스 (같은 리전, 다른 존) |
| **장애 감지** | 하트비트 기반 자동 감지 |
| **장애 조치 시간** | 약 60초 내외 |
| **데이터 동기화** | 동기식 복제 (데이터 손실 없음) |
| **비용** | 프라이머리 인스턴스의 약 2배 (스탠바이 비용 추가) |
| **자동 복구** | 장애 해결 후 자동으로 원래 구성 복원 |
| **SLA** | 99.95% 가용성 |

#### HA 설정
```bash
# 새 인스턴스를 HA로 생성
gcloud sql instances create my-mysql-ha \
    --database-version=MYSQL_8_0 \
    --tier=db-n1-standard-4 \
    --region=asia-northeast1 \
    --availability-type=REGIONAL \
    --storage-size=50GB \
    --storage-type=SSD

# 기존 인스턴스를 HA로 변경
gcloud sql instances patch my-mysql \
    --availability-type=REGIONAL

# HA를 단일 존으로 변경 (비용 절감)
gcloud sql instances patch my-mysql \
    --availability-type=ZONAL
```

#### 장애 조치 (Failover)
```bash
# 수동 장애 조치 (테스트용)
gcloud sql instances failover my-mysql-ha

# 인스턴스 상태 확인
gcloud sql instances describe my-mysql-ha \
    --format="value(state)"
```

---

### 7. 읽기 전용 복제본

#### 복제본 생성 및 관리
```bash
# 읽기 전용 복제본 생성
gcloud sql instances create my-mysql-read1 \
    --master-instance-name=my-mysql \
    --region=asia-northeast1 \
    --tier=db-n1-standard-2 \
    --storage-size=20GB

# 크로스 리전 복제본 (DR용)
gcloud sql instances create my-mysql-read-us \
    --master-instance-name=my-mysql \
    --region=us-central1 \
    --tier=db-n1-standard-2

# 복제본 목록 확인
gcloud sql instances list --filter="instanceType=READ_REPLICA_INSTANCE"

# 복제본 삭제
gcloud sql instances delete my-mysql-read1
```

#### 복제본을 독립 인스턴스로 승격
```bash
# 복제본 승격 (독립 인스턴스가 됨, 복제 관계 끊어짐)
gcloud sql instances promote-replica my-mysql-read1

# 승격 후 상태 확인
gcloud sql instances describe my-mysql-read1 \
    --format="value(instanceType)"
# 출력: CLOUD_SQL_INSTANCE (독립 인스턴스)
```

---

### 8. 유지보수 및 관리

#### 인스턴스 관리 명령어
```bash
# 인스턴스 목록
gcloud sql instances list

# 인스턴스 상세 정보
gcloud sql instances describe my-mysql

# 인스턴스 재시작
gcloud sql instances restart my-mysql

# 인스턴스 삭제 (삭제 보호가 없으면 즉시 삭제)
gcloud sql instances delete my-mysql
```

#### 머신 타입 변경
```bash
# 머신 타입 변경 (다운타임 발생)
gcloud sql instances patch my-mysql \
    --tier=db-n1-standard-4

# 커스텀 머신 타입 (vCPU 4개, RAM 16GB)
gcloud sql instances patch my-mysql \
    --tier=db-custom-4-16384
```

#### 스토리지 확장
```bash
# 스토리지 크기 확장 (축소 불가)
gcloud sql instances patch my-mysql \
    --storage-size=100GB

# 스토리지 자동 확장 활성화
gcloud sql instances patch my-mysql \
    --storage-auto-increase \
    --storage-auto-increase-limit=500GB
```

#### 유지보수 윈도우 설정
```bash
# 유지보수 윈도우 설정 (UTC 기준)
gcloud sql instances patch my-mysql \
    --maintenance-window-day=SUN \
    --maintenance-window-hour=2

# 유지보수 거부 기간 설정 (특정 기간 유지보수 차단)
gcloud sql instances patch my-mysql \
    --deny-maintenance-period-start-date=2026-12-20 \
    --deny-maintenance-period-end-date=2026-12-31 \
    --deny-maintenance-period-time=00:00:00
```

#### 데이터베이스 플래그 설정
```bash
# MySQL 플래그 설정
gcloud sql instances patch my-mysql \
    --database-flags=character_set_server=utf8mb4,\
max_connections=500,\
slow_query_log=on,\
long_query_time=2,\
innodb_buffer_pool_size=4294967296

# 현재 플래그 확인
gcloud sql instances describe my-mysql \
    --format="value(settings.databaseFlags)"

# 플래그 초기화 (모든 플래그 기본값으로)
gcloud sql instances patch my-mysql \
    --clear-database-flags
```

---

### 9. Cloud SQL 전체 구축 스크립트 예시

```bash
#!/bin/bash
# Cloud SQL (Private IP) + VM 연동 구축 스크립트

PROJECT_ID="named-foundry-486921-r5"
REGION="asia-northeast1"
ZONE="asia-northeast1-a"
VPC_NAME="pista-vpc"
INSTANCE_NAME="pista-mysql"

# 프로젝트 설정
gcloud config set project $PROJECT_ID

# 1. 필요한 API 활성화
echo "[1/7] API 활성화..."
gcloud services enable sqladmin.googleapis.com
gcloud services enable servicenetworking.googleapis.com

# 2. Private Service Access 설정 (VPC 피어링)
echo "[2/7] Private Service Access 설정..."
gcloud compute addresses create google-managed-services \
    --global \
    --purpose=VPC_PEERING \
    --prefix-length=16 \
    --network=$VPC_NAME

gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services \
    --network=$VPC_NAME

# 3. Cloud SQL 인스턴스 생성 (Private IP, HA)
echo "[3/7] Cloud SQL 인스턴스 생성..."
gcloud sql instances create $INSTANCE_NAME \
    --database-version=MYSQL_8_0 \
    --tier=db-custom-2-8192 \
    --region=$REGION \
    --network=$VPC_NAME \
    --no-assign-ip \
    --storage-size=20GB \
    --storage-type=SSD \
    --storage-auto-increase \
    --availability-type=REGIONAL \
    --backup-start-time=18:00 \
    --enable-bin-log \
    --maintenance-window-day=SUN \
    --maintenance-window-hour=17 \
    --database-flags=character_set_server=utf8mb4,max_connections=200 \
    --root-password=ChangeMe123!

# 4. 데이터베이스 생성
echo "[4/7] 데이터베이스 생성..."
gcloud sql databases create appdb \
    --instance=$INSTANCE_NAME \
    --charset=utf8mb4 \
    --collation=utf8mb4_unicode_ci

# 5. 애플리케이션 사용자 생성
echo "[5/7] 사용자 생성..."
gcloud sql users create appuser \
    --instance=$INSTANCE_NAME \
    --password=AppUserPass123! \
    --host=%

# 6. 읽기 전용 복제본 생성
echo "[6/7] 읽기 전용 복제본 생성..."
gcloud sql instances create ${INSTANCE_NAME}-read1 \
    --master-instance-name=$INSTANCE_NAME \
    --region=$REGION \
    --tier=db-custom-2-8192 \
    --storage-size=20GB

# 7. 상태 확인
echo "[7/7] 구축 완료! 상태 확인..."
PRIVATE_IP=$(gcloud sql instances describe $INSTANCE_NAME \
    --format="value(ipAddresses[0].ipAddress)")

echo ""
echo "========================================="
echo " Cloud SQL 구축 완료"
echo "========================================="
echo " 인스턴스: $INSTANCE_NAME"
echo " Private IP: $PRIVATE_IP"
echo " 데이터베이스: appdb"
echo " 사용자: appuser"
echo " 복제본: ${INSTANCE_NAME}-read1"
echo "========================================="
echo ""
echo "# VM에서 접속 테스트:"
echo "mysql -u appuser -p --host=$PRIVATE_IP appdb"
```