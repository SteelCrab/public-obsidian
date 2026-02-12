# GCP 스크립트 공통 모듈 (gcp-env.sh)

#gcp #스크립트 #공통 #헬퍼

---

모든 GCP 인프라 스크립트가 `source`하는 공통 환경 변수와 헬퍼 함수를 정리한다.

> 관련 문서: [[GCP_Infra_MOC]] | [[gcp-vpc]] | [[gcp-firewall]] | [[gcp-cloud-nat]]

## 사용 방법

```bash
source "$(dirname "$0")/gcp-env.sh"
```

---

## 공통 변수

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
| GKE | `$CLUSTER_NAME` / `$REPO_NAME` | `pista-cluster` / `pista-repo` |
| Image | `$IMG_NGINX` / `$IMG_FASTAPI` | `pista-nginx` / `pista-fastapi` |
| Source | `$PROJECT_ROOT` | `MZ-CLOUD/GCP/projects` |

---

## 헬퍼 함수

| 함수 | 용도 | 사용 예 |
|------|------|---------|
| `ensure_network` | VPC+서브넷+Router+NAT+방화벽 멱등 생성 | `ensure_network` (인자 없음) |
| `create_if_not_exists` | 리소스 존재 확인 후 생성 | `create_if_not_exists "check_cmd" "create_cmd" "라벨"` |
| `delete_if_exists` | 리소스 존재 확인 후 삭제 | `delete_if_exists "check_cmd" "delete_cmd" "라벨"` |
| `step` | 진행 헤더 출력 | `step 1 8 "VPC 생성 중..."` |
| `banner` | 스크립트 시작 배너 | `banner "VM 구축"` |
| `done_banner` | 완료 배너 | `done_banner "구축 완료!"` |

---

## ensure_network 상세

VPC가 필요한 모듈(VM, SQL, LB, 심플)에서 자동 호출되며, 아래 리소스를 멱등하게 생성한다.

```
ensure_network()
├── VPC (pista-vpc, Custom Mode)
├── Public 서브넷 (10.0.1.0/24)
├── Private 서브넷 (10.0.2.0/24, Private Google Access)
├── Cloud Router (pista-router)
├── Cloud NAT (pista-nat)
├── 방화벽: SSH (tcp:22, 0.0.0.0/0)
├── 방화벽: HTTP (tcp:80,443, tag:http-server)
├── 방화벽: 내부 통신 (all, 10.0.0.0/8)
└── 방화벽: 헬스 체크 (tcp:80, Google HC 대역)
```

> 이미 존재하는 리소스는 건너뛴다 (멱등).
