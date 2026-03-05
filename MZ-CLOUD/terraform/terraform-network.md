# GCP Terraform 튜토리얼 (1): 네트워크 (VPC)

#gcp #terraform #vpc #network

---

GCP 인프라 구축의 첫 번째 단계인 **네트워크(VPC)** 구성입니다.
VM이나 GKE 등 모든 컴퓨팅 리소스는 이 네트워크 위에 생성됩니다.

> **구조**: `terraform-network` 폴더에서 별도 관리하거나, `terraform-lab`에서 먼저 적용합니다.

## 1. 프로젝트 설정
작업 디렉토리를 생성하고 진입합니다.

```bash
mkdir -p terraform-network
cd terraform-network
```

## 2. Terraform 코드 작성

### 2.1 `provider.tf`
```hcl
provider "google" {
  project = "<YOUR_PROJECT_ID>"
  region  = "asia-northeast3"
}
```

### 2.2 `network.tf` (VPC/Subnet/Firewall)
```hcl
# 1. VPC 만들기
resource "google_compute_network" "vpc" {
  name                    = "pista-vpc-tf"
  auto_create_subnetworks = false # 커스텀 모드
}

# 2. 서브넷 만들기
resource "google_compute_subnetwork" "subnet" {
  name          = "pista-public-subnet-tf"
  ip_cidr_range = "10.0.1.0/24"
  region        = "asia-northeast3"
  network       = google_compute_network.vpc.id
}

# 3. 방화벽 규칙 (SSH 허용)
resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh-tf"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}
```

### 2.3 `outputs.tf` (중요)
다른 프로젝트(VM, GKE)에서 참조할 수 있도록 네트워크 이름을 출력합니다.

```hcl
output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.subnet.name
}
```

## 3. 실행 (Apply)

```bash
terraform init
terraform apply
```

생성이 완료되면 다음 단계([[terraform-vm]])로 넘어갑니다.
