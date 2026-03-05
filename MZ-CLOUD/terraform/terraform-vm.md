# GCP Terraform 튜토리얼 (2): VM 인스턴스 (Compute)

#gcp #terraform #vm #compute

---

이전 단계([[terraform-network]])에서 생성한 VPC 위에 **VM 인스턴스(Nginx)**를 배포하는 과정입니다.
네트워크와 컴퓨팅 리소스를 분리하여 관리합니다.

## 1. 사전 준비
**네트워크 구축 필수**: `terraform-network` 단계가 완료되어 있어야 합니다.

```bash
mkdir -p terraform-vm
cd terraform-vm
```

## 2. Terraform 코드 작성

### 2.1 `provider.tf`
```hcl
provider "google" {
  project = "<YOUR_PROJECT_ID>"
  region  = "asia-northeast3"
}
```

### 2.2 `data.tf` (네트워크 참조)
기존에 생성된 VPC와 서브넷 정보를 가져옵니다.

```hcl
data "google_compute_network" "vpc" {
  name = "pista-vpc-tf"
}

data "google_compute_subnetwork" "subnet" {
  name   = "pista-public-subnet-tf"
  region = "asia-northeast3"
}
```

### 2.3 `compute.tf` (VM 생성)
가져온 네트워크 정보(`data source`)를 사용하여 VM을 생성합니다.

```hcl
resource "google_compute_instance" "vm" {
  name         = "pista-vm-tf"
  machine_type = "e2-micro"
  zone         = "asia-northeast3-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2404-lts-amd64"
    }
  }

  network_interface {
    # Data Source 참조
    network    = data.google_compute_network.vpc.id
    subnetwork = data.google_compute_subnetwork.subnet.id
    
    access_config {
      # Public IP 할당
    }
  }

  metadata_startup_script = "apt-get update && apt-get install -y nginx"
}
```

## 3. 실행 (Apply)

```bash
terraform init
terraform apply
```

## 4. 확인 및 정리

```bash
# 생성된 VM 확인
gcloud compute instances list

# VM 삭제 (네트워크는 유지됨)
terraform destroy
```
