# GCP 인프라 구축 스크립트 가이드

#gcp #scripts #automation

---

`MZ-CLOUD/GCP/scripts/` 디렉토리에 있는 자동화 스크립트 사용법입니다.

## 📋 사전 요구사항

1. **gcloud CLI 설치 및 인증**
   ```bash
   gcloud auth login
   gcloud config set project [PROJECT_ID]
   ```

2. **실행 권한 부여**
   ```bash
   cd MZ-CLOUD/GCP/scripts
   chmod +x *.sh
   ```

---

## 🚀 실행 프로세스 (Workflow)

### 1단계: 네트워크 구성
모든 리소스의 기반이 되는 VPC, 서브넷, 방화벽을 생성합니다.
* **구축**: `bash gcp-network-setup.sh`
* **삭제**: `bash gcp-network-cleanup.sh`
> **주의**: 이 스크립트를 가장 먼저 실행해야 합니다.

### 2단계: 리소스 배포 
필요한 리소스를 선택하여 구축합니다.

| 분류 | 구축 스크립트 | 삭제 스크립트 | 설명 |
|------|--------------|--------------|------|
| **Network** | `gcp-network-setup.sh` | `gcp-network-cleanup.sh` | [[gcp-script-network]] |
| **VM** | `gcp-vm-setup.sh` | `gcp-vm-cleanup.sh` | [[gcp-script-vm]] |
| **GKE** | `gcp-gke-setup.sh` | `gcp-gke-cleanup.sh` | [[gcp-script-gke]] |
| **DB** | `gcp-cloudsql-setup.sh` | `gcp-cloudsql-cleanup.sh` | [[gcp-script-cloudsql]] |
| **LB** | `gcp-lb-setup.sh` | `gcp-lb-cleanup.sh` | [[gcp-script-lb]] |
| **GCS** | `gcp-gcs-setup.sh` | `gcp-gcs-cleanup.sh` | [[gcp-script-gcs]] |

---

## 🛠️ 주요 환경 변수 (`gcp-env.sh`)

프로젝트 전반의 설정값은 이 파일에서 수정합니다.

* `PROJECT_ID`: gcloud 현재 프로젝트
* `REGION`: `asia-northeast3` (서울)
* `VPC_NAME`: `pista-vpc`
* `CLUSTER_NAME`: `pista-cluster` (GKE)
* `REPO_NAME`: `pista-repo` (GAR)
* `PROJECT_ROOT`: 소스 코드 경로 (`MZ-CLOUD/GCP/projects`)

---

## ⚠️ 문제 해결

- **VPC not found**: `gcp-network-setup.sh`를 실행했는지 확인하세요.
- **Permission denied**: `chmod +x` 명령어로 실행 권한을 부여하세요.
- **Quota exceeded**: GCP 할당량을 초과했는지 확인하세요 (특히 IP 주소, CPU).
