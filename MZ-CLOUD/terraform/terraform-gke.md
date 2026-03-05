# GCP Terraform 튜토리얼 (심화): GKE 구축

#gcp #terraform #gke #kubernetes

---

이전 단계([Terraform MOC](./Terraform_MOC.md))에서 구축한 VPC 위에 **GKE 클러스터**를 생성하는 과정입니다.

## 1. 사전 준비
이전 튜토리얼(`terraform-lab` 폴더)의 상태(`terraform.tfstate`)가 유지된 상태여야 합니다.
(만약 `destroy` 했다면 `terraform apply`로 다시 VPC를 생성해주세요.)

## 2. GKE 구성 추가

### 2.1 `variables.tf` (변수 정의)
클러스터 설정값을 변수로 관리합니다.

```hcl
variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

variable "gke_machine_type" {
  default     = "e2-medium"
  description = "machine type"
}
```

### 2.2 `gke.tf` (클러스터 및 노드풀)
GKE 클러스터와 노드풀을 정의합니다. VPC와 서브넷을 참조합니다.

```hcl
# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = "pista-cluster-tf"
  location = "asia-northeast3-a" # Zonal Cluster

  # VPC & Subnet
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  # Autopilot 대신 Standard 모드 사용 시 삭제 불가능한 기본 노드풀 제거
  remove_default_node_pool = true
  initial_node_count       = 1
  
  # IP Alias (VPC-native)
  ip_allocation_policy {}
}

# Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "pista-node-pool"
  location   = "asia-northeast3-a"
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    machine_type = var.gke_machine_type
    
    # Google Cloud Platform 스코프 (최소 권한)
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      pista-env = "terraform-lab"
    }

    tags = ["gke-node"]
  }
}
```

### 2.3 `outputs.tf` (출력값)
생성 후 접속 명령어를 출력하도록 설정합니다.

```hcl
output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "get_credentials_command" {
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region asia-northeast3-a"
  description = "Command to configure kubectl"
}
```

---

## 3. 실행 및 검증

### 3.1 적용
새로운 리소스(Cluster, Node Pool)가 추가됩니다.

```bash
terraform apply
# Plan 확인 후 yes
```
> **참고**: GKE 클러스터 생성은 약 5~10분 정도 소요됩니다.

### 3.2 접속 테스트
출력된 명령어로 `kubectl` 인증을 설정합니다.

```bash
# 인증 가져오기
gcloud container clusters get-credentials pista-cluster-tf --zone asia-northeast3-a

# 노드 확인
kubectl get nodes
```

### 3.3 정리 (Destroy)
클러스터를 포함한 모든 리소스를 삭제합니다.

```bash
terraform destroy
```

---

## 4. 다음 단계
- [ ] **Artifact Registry**: `google_artifact_registry_repository` 리소스 추가
- [ ] **Kubernetes Manifest**: `kubernetes` Provider를 사용하여 Deployment 배포
