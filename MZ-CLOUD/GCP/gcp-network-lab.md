# GCP 네트워크 구축 실습

#gcp #네트워크 #실습 #구축

---

GCP 네트워크 인프라를 실습으로 구축하는 과정을 정리한다. AWS와의 비교, 전체 구축 스크립트, 테스트 방법을 포함한다.

> 관련 문서: [[gcp-vpc]], [[gcp-cloud-nat]], [[gcp-firewall]], [[gcp-cli]]

## AWS vs GCP 네트워크 서비스 비교

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

---

## Cloud VPC 생성

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

## 전체 구축 스크립트 예시

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

## 전체 구축 - 웹 콘솔 버전

### 1단계: VPC 생성

> 📍 VPC 네트워크 > VPC 네트워크 만들기

1. **이름**: `pista-vpc` 입력
2. **서브넷 생성 모드**: `커스텀` 선택
3. **동적 라우팅 모드**: `리전` 선택
4. **만들기** 클릭

### 2단계: 서브넷 생성

> 📍 VPC 네트워크 > pista-vpc > 서브넷 > 서브넷 추가

**Public 서브넷:**
1. **이름**: `public-subnet` 입력
2. **리전**: `asia-northeast1` 선택
3. **IPv4 범위**: `10.0.1.0/24` 입력
4. **추가** 클릭

**Private 서브넷:**
1. **이름**: `private-subnet` 입력
2. **리전**: `asia-northeast1` 선택
3. **IPv4 범위**: `10.0.2.0/24` 입력
4. **비공개 Google 액세스**: `사용` 선택
5. **추가** 클릭

### 3단계: Cloud Router 생성

> 📍 하이브리드 연결 > Cloud Router > 라우터 만들기

1. **이름**: `pista-router` 입력
2. **네트워크**: `pista-vpc` 선택
3. **리전**: `asia-northeast1` 선택
4. **만들기** 클릭

### 4단계: Cloud NAT 생성

> 📍 네트워크 서비스 > Cloud NAT > NAT 게이트웨이 만들기

1. **게이트웨이 이름**: `pista-nat` 입력
2. **Cloud Router**: `pista-router` 선택
3. **소스**: `모든 서브넷의 모든 기본 IP 범위` 선택
4. **NAT IP 주소**: `자동` 선택
5. **만들기** 클릭

### 5단계: 방화벽 규칙 생성

> 📍 VPC 네트워크 > 방화벽 > 방화벽 규칙 만들기

아래 규칙을 각각 생성:

| **규칙 이름** | **프로토콜/포트** | **소스 범위** | **대상** |
|-------------|---------------|-------------|---------|
| `allow-ssh` | TCP:22 | `0.0.0.0/0` | 모든 인스턴스 |
| `allow-http-https` | TCP:80,443 | `0.0.0.0/0` | 태그: `web-server` |
| `allow-internal` | 모든 프로토콜 | `10.0.0.0/8` | 모든 인스턴스 |

---

## 테스트 및 검증

### VM 인스턴스 생성으로 테스트

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

### VM 인스턴스 생성 - 웹 콘솔

> 📍 Compute Engine > VM 인스턴스 > 인스턴스 만들기

**Public 웹 서버:**
1. **이름**: `web-server` 입력
2. **리전/존**: `asia-northeast1-a` 선택
3. **네트워킹** > 서브넷: `public-subnet` 선택
4. **네트워크 태그**: `web-server` 입력
5. **관리** > 자동화 > 시작 스크립트에 nginx 설치 스크립트 붙여넣기
6. **만들기** 클릭

**Private DB 서버:**
1. **이름**: `db-server` 입력
2. **리전/존**: `asia-northeast1-a` 선택
3. **네트워킹** > 서브넷: `private-subnet` 선택
4. **네트워킹** > 외부 IPv4 주소: `없음` 선택
5. **만들기** 클릭

### 라우팅 및 연결성 확인

```bash
# 라우팅 테이블 확인
gcloud compute routes list --filter="network=pista-vpc"

# NAT 상태 확인
gcloud compute routers get-status pista-router --region=$REGION

# 방화벽 규칙 적용 확인
gcloud compute firewall-rules describe allow-ssh
```

---

## 주요 차이점 정리 (AWS vs GCP)

| **항목**  | **AWS**                        | **GCP**                  |
| ------- | ------------------------------ | ------------------------ |
| **IGW** | 명시적으로 생성 및 연결 필요               | 암시적 제공 (외부 IP 있으면 자동 연결) |
| **NAT** | NAT Instance 또는 NAT Gateway 생성 | Cloud NAT (관리형 서비스)      |
| **서브넷** | AZ 종속                          | 리전 종속 (여러 존에 걸침)         |
| **라우팅** | 라우팅 테이블 명시적 관리                 | 자동 라우팅 (수동 관리도 가능)       |
| **방화벽** | Security Group + NACL          | VPC 방화벽 규칙 (태그 기반)       |

---

## 구축 스크립트 구현 (2026-02-10)

![[gcp-pista-vpc.png]]

### 프로젝트 정보

| **항목**         | **값**                     |
| -------------- | ------------------------- |
| **Project ID** | `named-foundry-486921-r5` |
| **Region**     | `asia-northeast1` (도쿄)    |
| **Zone**       | `asia-northeast1-a`       |

### 구축된 리소스

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

### 스크립트 파일

| **파일**              | **용도**                            | **실행**                   |
| ------------------- | --------------------------------- | ------------------------ |
| `gcp-vm-setup.sh`   | VPC + 서브넷 + NAT + 방화벽 + VM 생성     | `bash gcp-vm-setup.sh`   |
| `gcp-vm-test.sh`    | Nginx 접속 및 내부 통신 테스트 (Bastion 경유) | `bash gcp-vm-test.sh`    |
| `gcp-vm-cleanup.sh` | 모든 리소스 정리 (삭제)                    | `bash gcp-vm-cleanup.sh` |

### 구축 프로세스 (setup.sh 9단계)

```
[1/9] VPC 생성 (pista-vpc, Custom Mode)
[2/9] Public 서브넷 생성 (10.0.1.0/24)
[3/9] Private 서브넷 생성 (10.0.2.0/24)
[4/9] Cloud Router 생성
[5/9] Cloud NAT 생성 (Private 아웃바운드용)
[6/9] 방화벽 규칙 생성 (SSH, HTTP, 내부통신, MySQL)
[7/9] Public 인스턴스 생성 + Nginx 설치
[8/9] Private 인스턴스 생성 + Nginx 설치
[9/9] MySQL 인스턴스 생성 + MySQL 8.0 설치 및 설정
```

### 테스트 방법 (test.sh 6단계)

```
[1/6] Public 서버 외부 접속 (curl http://35.194.98.14)
[2/6] Public 서버 Nginx 상태 확인 (systemctl status)
[3/6] Public → Private 내부 통신 (curl http://10.0.2.2)
[4/6] Private 서버 NAT 테스트 (Public Bastion 경유)
[5/6] MySQL 접속 테스트 (Public 서버에서 mysql -h <MYSQL_IP>)
[6/6] MySQL 서버 SSH 접속 (Public Bastion 경유)
```

### Private 서버 접속 방법 (Bastion 경유)

```bash
# IAP 권한이 없는 경우 Public 서버를 Bastion으로 사용
gcloud compute ssh public-nginx-server --zone=asia-northeast1-a

# Public 서버 안에서 Private 서버로 SSH
ssh 10.0.2.2

# Public 서버 안에서 MySQL 접속 테스트
mysql -h <MYSQL_PRIVATE_IP> -u appuser -pAppUser456! appdb
```

### 리소스 정리 (cleanup.sh 6단계)

```
[1/6] VM 인스턴스 삭제 (public-nginx, private-nginx, private-mysql)
[2/6] 방화벽 규칙 삭제 (SSH, HTTP, 내부통신, MySQL)
[3/6] Cloud NAT 삭제
[4/6] Cloud Router 삭제
[5/6] 서브넷 삭제
[6/6] VPC 삭제
```
