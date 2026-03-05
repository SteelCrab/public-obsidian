# GCP Terraform 튜토리얼 (목차)

#gcp #terraform #iac #MOC

---

GCP 인프라를 **Terraform (IaC)**으로 관리하기 위한 단계별 가이드입니다.
네트워크(VPC)와 컴퓨팅 리소스(VM, GKE, LB)를 모듈화하여 관리하는 방법을 다룹니다.

## 1. 사전 요구사항
- **Terraform 설치**: [[terraform-install]] 참고 (`brew install terraform`)
- **GCP 인증**: `gcloud auth application-default login`

## 참고 자료

### 환경 설정
- [[terraform-install]] - Terraform 설치 가이드 (macOS / Windows)
- [[terraform-vscode]] - VSCode 확장 설치 및 설정 (formatOnSave)
- [[terraform-doc-multi-agent]] - Opus + Gemini CLI 병렬 문서 운영 가이드

### AWS 기초 실습 (aws-basic)
- [provider](./terraform-lab/aws-basic0/provider.md) - provider.tf (CSP, 버전, 리전)
- [main](./terraform-lab/aws-basic0/main.md) - main.tf
- [[terraform-lab/aws-base2/README]] - ALB 실습 (2개 AZ + 2개 EC2 + ALB)
- [[terraform-lab/aws-base3/README]] - ALB + ASG 실습 (Private Subnet Auto Scaling)
- [[terraform-lab/aws-base5-rds/README]] - RDS 실습 (Bastion + MySQL + 격리 서브넷)
- [[terraform-lab/aws-base6-3tier/README]] - 3-Tier 실습 (ALB + ASG(nginx/fastAPI) + RDS Primary/Replica)

### 비교 / 레퍼런스
- [[terraform-resource-types]] - AWS vs GCP 주요 리소스 유형 비교

## 2. 튜토리얼 목차

### 기초 (Basic)
1. **[[terraform-network]]**: 네트워크 (VPC, Subnet, Firewall) 구축
   - 가장 먼저 실행해야 하는 기반 인프라입니다.
2. **[[terraform-vm]]**: VM 인스턴스 구축
   - 생성된 네트워크를 참조(`data source`)하여 VM을 배포합니다.

### 심화 (Advanced)
3. **[[terraform-gke]]**: GKE 클러스터 구축
   - VPC 위에 Kubernetes 클러스터를 생성합니다.
4. **[[terraform-lb]]**: Load Balancer + MIG 구축
   - 인스턴스 그룹과 로드밸런서를 구성합니다.
## 날짜
[[2026-02-19]]
