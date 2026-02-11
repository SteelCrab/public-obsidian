# GCP 인프라 구축 스크립트

pista-vpc 기반 GCP 인프라를 모듈별로 구축하는 스크립트 모음.
각 모듈은 독립 실행 가능 — 필요한 모듈만 아무 순서로 실행.

## 아키텍처

```
pista-vpc (Custom Mode)
├── pista-public-subnet  (10.0.1.0/24)
│   ├── pista-public-nginx (외부 IP)
│   ├── pista-pub-nginx (심플 VM)
│   └── pista-web-mig (LB 백엔드, 2~5대)
│
├── pista-private-subnet (10.0.2.0/24, Private Google Access)
│   ├── pista-private-nginx (내부 전용)
│   ├── pista-priv-nginx (심플 VM)
│   └── Cloud SQL - pista-mysql (Private IP, VPC 피어링)
│
├── Cloud Router (pista-router)
│   └── Cloud NAT (pista-nat)
│
├── 방화벽 규칙
│   ├── allow-ssh-pista-vpc      : tcp:22 (0.0.0.0/0)
│   ├── allow-http-pista-vpc     : tcp:80,443 (0.0.0.0/0) → tag:http-server
│   ├── allow-internal-pista-vpc : all (10.0.0.0/8)
│   └── allow-health-check-pista-vpc : tcp:80 (Google HC 대역)
│
├── HTTP Load Balancer (MIG 백엔드)
│   ├── 전역 IP (pista-lb-ip)
│   ├── Forwarding Rule → HTTP Proxy → URL Map
│   └── Backend Service → pista-web-mig
│
└── Static Site LB (GCS 백엔드)
    ├── 전역 IP (pista-static-lb-ip)
    ├── Forwarding Rule → HTTP Proxy → URL Map
    └── Backend Bucket (CDN) → GCS 버킷
```

## 파일 구조

```
scripts/
├── gcp-env.sh                # 공통 변수 + 헬퍼 함수 + ensure_network()
│
├── gcp-vm-setup.sh           # [VM 모듈] VPC + VM 2대
├── gcp-cloudsql-setup.sh     # [SQL 모듈] Cloud SQL (Private IP)
├── gcp-lb-setup.sh           # [LB 모듈] 인스턴스 템플릿 + MIG + LB
├── gcp-gcs-setup.sh          # [GCS 모듈] GCS + LB (정적 사이트 + CDN)
├── gcp-simple-setup.sh       # [심플 모듈] VM 2대 (Public + Private)
│
├── gcp-vm-cleanup.sh         # VM 모듈 정리
├── gcp-cloudsql-cleanup.sh   # SQL 모듈 정리
├── gcp-lb-cleanup.sh         # LB 모듈 정리
├── gcp-gcs-cleanup.sh        # GCS 모듈 정리
├── gcp-simple-cleanup.sh     # 심플 모듈 정리 (VM만)
├── gcp-network-cleanup.sh    # 공유 네트워크 정리 (VPC/서브넷/NAT/방화벽)
│
├── gcp-pista-vpc.png         # 아키텍처 다이어그램
├── README.md
└── legacy/                   # 구 버전 (단일 스크립트)
    ├── gcp-vm-setup.sh
    ├── gcp-vm-test.sh
    ├── gcp-vm-cleanup.sh
    ├── gcp-mysql-setup.sh
    ├── gcp-mysql-test.sh
    └── gcp-mysql-cleanup.sh
```

## 모듈 목록

### Setup (모든 모듈 독립 실행 가능)

| 모듈 | 파일 | 용도 |
|------|------|------|
| 공통 | `gcp-env.sh` | 공통 변수 + 헬퍼 함수 + `ensure_network()` |
| VM | `gcp-vm-setup.sh` | VPC + VM 2대 (Public + Private) |
| SQL | `gcp-cloudsql-setup.sh` | Cloud SQL (Private IP) + DB + 사용자 |
| LB | `gcp-lb-setup.sh` | 인스턴스 템플릿 + MIG + HTTP LB |
| GCS | `gcp-gcs-setup.sh` | GCS 버킷 + HTTP LB (정적 사이트 + CDN) |
| 심플 | `gcp-simple-setup.sh` | 심플 VM 2대 (Public + Private) |

> VPC가 필요한 모듈(VM, SQL, LB, 심플)은 `ensure_network()`로 자동 생성.
> GCS 모듈은 VPC 불필요.

### Cleanup (각 모듈 리소스만 삭제, VPC는 유지)

| 파일 | 삭제 대상 |
|------|----------|
| `gcp-vm-cleanup.sh` | Public VM + Private VM |
| `gcp-cloudsql-cleanup.sh` | Cloud SQL + Private Service Access |
| `gcp-lb-cleanup.sh` | LB 전체 (Forwarding → Proxy → URL Map → Backend → MIG → Health Check → Template → IP) |
| `gcp-gcs-cleanup.sh` | GCS LB + 버킷 (공개 설정은 버킷 삭제 시 같이 제거) |
| `gcp-simple-cleanup.sh` | 심플 VM 2대 |
| `gcp-network-cleanup.sh` | 공유 네트워크 (방화벽 → NAT → Router → 서브넷 → VPC) |

## 공통 모듈 (`gcp-env.sh`)

모든 스크립트는 `source "$(dirname "$0")/gcp-env.sh"`로 공통 설정을 로드한다.

### 공통 변수

| 카테고리 | 변수 | 값 |
|---------|------|-----|
| 프로젝트 | `$PROJECT_ID` | gcloud config에서 자동 획득 |
| 리전 | `$REGION` / `$ZONE` | `asia-northeast1` / `asia-northeast1-a` |
| 네트워크 | `$VPC_NAME` | `pista-vpc` |
| 서브넷 | `$PUBLIC_SUBNET` / `$PRIVATE_SUBNET` | `pista-public-subnet` / `pista-private-subnet` |
| NAT | `$ROUTER_NAME` / `$NAT_NAME` | `pista-router` / `pista-nat` |
| 방화벽 | `$FW_SSH` / `$FW_HTTP` / `$FW_INTERNAL` / `$FW_HEALTH` | `allow-*-pista-vpc` |
| VM | `$PUBLIC_INSTANCE` / `$PRIVATE_INSTANCE` | `pista-public-nginx` / `pista-private-nginx` |
| SQL | `$SQL_INSTANCE` / `$DB_NAME` / `$DB_USER` | `pista-mysql` / `pista-appdb` / `pista-user` |
| LB | `$TEMPLATE_NAME` / `$MIG_NAME` / `$LB_IP_NAME` | `pista-web-template` / `pista-web-mig` / `pista-lb-ip` |
| GCS | `$GCS_BUCKET` / `$GCS_LB_IP` | `pista-static-site` / `pista-static-lb-ip` |
| Simple | `$SIMPLE_PUBLIC_VM` / `$SIMPLE_PRIVATE_VM` | `pista-pub-nginx` / `pista-priv-nginx` |

### 헬퍼 함수

| 함수 | 용도 | 사용 예 |
|------|------|---------|
| `ensure_network` | VPC+서브넷+Router+NAT+방화벽 멱등 생성 | `ensure_network` (인자 없음) |
| `create_if_not_exists` | 리소스 존재 확인 후 생성 | `create_if_not_exists "check_cmd" "create_cmd" "라벨"` |
| `delete_if_exists` | 리소스 존재 확인 후 삭제 | `delete_if_exists "check_cmd" "delete_cmd" "라벨"` |
| `step` | 진행 헤더 출력 | `step 1 8 "VPC 생성 중..."` |
| `banner` | 스크립트 시작 배너 | `banner "VM 구축"` |
| `done_banner` | 완료 배너 | `done_banner "구축 완료!"` |

## 실행 방법

### 사전 조건

```bash
gcloud auth login
gcloud config set project <PROJECT_ID>
gcloud services enable compute.googleapis.com sqladmin.googleapis.com servicenetworking.googleapis.com
```

### 모듈 실행 (아무 순서로 필요한 모듈만)

```bash
bash gcp-vm-setup.sh           # VPC + VM
bash gcp-cloudsql-setup.sh     # Cloud SQL (약 10분)
bash gcp-lb-setup.sh           # Load Balancer
bash gcp-gcs-setup.sh          # GCS 정적 사이트 + LB (VPC 불필요)
bash gcp-simple-setup.sh       # 심플 VM 2대
```

> 각 모듈은 `ensure_network()`로 VPC를 자동 확인/생성하므로 순서 무관.
> 이미 생성된 리소스는 건너뛴다 (멱등).

### 정리

```bash
# 모듈별 정리 (자기 리소스만 삭제, VPC 유지)
bash gcp-vm-cleanup.sh
bash gcp-cloudsql-cleanup.sh
bash gcp-lb-cleanup.sh
bash gcp-gcs-cleanup.sh
bash gcp-simple-cleanup.sh

# 공유 네트워크 정리 (모든 모듈 리소스 삭제 후 실행)
bash gcp-network-cleanup.sh
```

## 각 모듈 상세

### VM 모듈 (`gcp-vm-setup.sh`)

| 리소스 | 설명 |
|--------|------|
| 공유 네트워크 | VPC+서브넷+Router+NAT+방화벽 — `ensure_network()` |
| Public VM | `pista-public-nginx` (외부 IP + Nginx) |
| Private VM | `pista-private-nginx` (내부 전용 + Nginx) |

### Cloud SQL 모듈 (`gcp-cloudsql-setup.sh`)

| 리소스 | 설명 |
|--------|------|
| Private Service Access | VPC 피어링 (Google 관리형 서비스용) |
| Cloud SQL 인스턴스 | `pista-mysql` (MySQL 8.0, Private IP) |
| 데이터베이스 | `pista-appdb` (utf8mb4) |
| 사용자 | `pista-user` (원격 접속 허용) |

> Cleanup 시 IP 범위(`google-managed-services-*`) 삭제로 VPC 피어링도 함께 정리된다.

```bash
# VPC 내부 VM에서
mysql -h <PRIVATE_IP> -u pista-user -pAppUser456! pista-appdb

# 로컬에서 Auth Proxy
./cloud-sql-proxy <CONNECTION_NAME> --port=3306
mysql -h 127.0.0.1 -u pista-user -pAppUser456! pista-appdb
```

### Load Balancer 모듈 (`gcp-lb-setup.sh`)

| 리소스 | 설명 |
|--------|------|
| 인스턴스 템플릿 | `pista-web-template` (e2-micro + Nginx) |
| 헬스 체크 | `pista-health-check` (HTTP:80) |
| MIG | `pista-web-mig` (리전, 2~5대, 오토스케일링) |
| 백엔드 서비스 | `pista-backend-service` (MIG 연결) |
| URL Map | `pista-url-map` (기본 라우팅) |
| HTTP Proxy | `pista-http-proxy` |
| 전역 IP + Forwarding Rule | `pista-lb-ip` → HTTP:80 |

```bash
# LB 테스트 (프로비저닝 후 1~3분 대기)
curl http://<LB_IP>

# 분산 확인
for i in $(seq 1 10); do curl -s http://<LB_IP> | grep Instance; done
```

### GCS 모듈 (`gcp-gcs-setup.sh`)

VPC 불필요 — 완전 독립 실행.

| 리소스 | 설명 |
|--------|------|
| GCS 버킷 | `pista-static-site` |
| 공개 설정 | `allUsers` → `objectViewer` |
| 정적 파일 업로드 | `index.html`, `404.html` |
| 백엔드 버킷 | `pista-static-backend` (CDN 활성화) |
| URL Map | `pista-static-url-map` |
| HTTP Proxy | `pista-static-http-proxy` |
| 전역 IP + Forwarding Rule | `pista-static-lb-ip` → HTTP:80 |

```
클라이언트 → 전역 IP → HTTP Proxy → URL Map → Backend Bucket (CDN) → GCS 버킷
```

### 심플 VM 모듈 (`gcp-simple-setup.sh`)

최소 구성 VM 2대.

| 리소스 | 설명 |
|--------|------|
| `pista-pub-nginx` | Public 서브넷, 외부 IP, Nginx |
| `pista-priv-nginx` | Private 서브넷, 내부 전용, Nginx |

```
pista-public-subnet  → pista-pub-nginx  (외부 IP + Nginx)
pista-private-subnet → pista-priv-nginx (내부 전용, NAT 아웃바운드)
```

## 관련 노트

- [[gcp-vpc]] | [[gcp-cloud-nat]] | [[gcp-firewall]]
- [[gcp-compute-engine]] | [[gcp-instance-template]]
- [[gcp-cloud-sql]] | [[gcp-cloud-sql-connect]]
- [[gcp-load-balancer]] | [[gcp-storage-bucket]]
