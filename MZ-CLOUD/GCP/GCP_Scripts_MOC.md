# GCP 인프라 구축 스크립트

#gcp #스크립트 #인프라 #moc

---

pista-vpc 기반 GCP 인프라를 모듈별로 구축하는 스크립트 모음.
각 모듈은 독립 실행 가능 — 필요한 모듈만 아무 순서로 실행.

## 아키텍처

![[gcp-pista-vpc.png]]

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

---

## 공통 모듈

- [[gcp-script-env]] - 공통 변수 + 헬퍼 함수 + `ensure_network()`

---

## Setup 모듈 (모든 모듈 독립 실행 가능)

- [[gcp-script-vm]] - VPC + VM 2대 (Public + Private)
- [[gcp-script-cloudsql]] - Cloud SQL (Private IP) + DB + 사용자
- [[gcp-script-lb]] - 인스턴스 템플릿 + MIG + HTTP LB
- [[gcp-script-gcs]] - GCS 버킷 + HTTP LB (정적 사이트 + CDN)
- [[gcp-script-simple]] - 심플 VM 2대 (Public + Private)

> VPC가 필요한 모듈(VM, SQL, LB, 심플)은 `ensure_network()`로 자동 생성.
> GCS 모듈은 VPC 불필요.

---

## 사전 조건

```bash
gcloud auth login
gcloud config set project <PROJECT_ID>
gcloud services enable compute.googleapis.com sqladmin.googleapis.com servicenetworking.googleapis.com
```

---

## 실행 방법

```bash
bash gcp-vm-setup.sh           # VPC + VM
bash gcp-cloudsql-setup.sh     # Cloud SQL (약 10분)
bash gcp-lb-setup.sh           # Load Balancer
bash gcp-gcs-setup.sh          # GCS 정적 사이트 + LB (VPC 불필요)
bash gcp-simple-setup.sh       # 심플 VM 2대
```

> 각 모듈은 `ensure_network()`로 VPC를 자동 확인/생성하므로 순서 무관.
> 이미 생성된 리소스는 건너뛴다 (멱등).

---

## 정리

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

| 파일 | 삭제 대상 |
|------|----------|
| `gcp-vm-cleanup.sh` | Public VM + Private VM |
| `gcp-cloudsql-cleanup.sh` | Cloud SQL + Private Service Access |
| `gcp-lb-cleanup.sh` | LB 전체 (Forwarding → Proxy → URL Map → Backend → MIG → Template → IP) |
| `gcp-gcs-cleanup.sh` | GCS LB + 버킷 |
| `gcp-simple-cleanup.sh` | 심플 VM 2대 |
| `gcp-network-cleanup.sh` | 공유 네트워크 (방화벽 → NAT → Router → 서브넷 → VPC) |

---

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
└── gcp-pista-vpc.png         # 아키텍처 다이어그램
```

---

## 관련 노트

- [[gcp-vpc]] | [[gcp-cloud-nat]] | [[gcp-firewall]]
- [[gcp-compute-engine]] | [[gcp-instance-template]]
- [[gcp-cloud-sql]] | [[gcp-cloud-sql-connect]]
- [[gcp-load-balancer]] | [[gcp-storage-bucket]]
