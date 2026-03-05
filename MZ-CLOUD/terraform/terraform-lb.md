# GCP Terraform 튜토리얼 (심화): Load Balancer (MIG)

#gcp #terraform #mig #lb

---

이전 단계([Terraform MOC](./Terraform_MOC.md))에서 구축한 VPC 위에 **Managed Instance Group (MIG)**과 **HTTP Load Balancer**를 생성하는 과정입니다.

## 1. 사전 준비
이전 튜토리얼(`terraform-lab` 폴더)의 상태가 유지된 상태여야 합니다.
(만약 `destroy` 했다면 `terraform apply`로 다시 VPC를 생성해주세요.)

> **주의**: 기존 `compute.tf`의 단일 VM(`google_compute_instance`)과 충돌할 수 있으므로, `compute.tf` 파일의 확장자를 변경(`.tf.bak`)하거나 해당 리소스를 주석 처리하는 것을 권장합니다.

## 2. LB 구성 요소

### 2.1 `variables.tf` (추가)

```hcl
variable "mig_size" {
  default     = 2
  description = "Number of instances in MIG"
}
```

### 2.2 `instance_template.tf`
VM의 청사진(Template)을 정의합니다.

```hcl
resource "google_compute_instance_template" "template" {
  name_prefix  = "pista-template-"
  machine_type = "e2-micro"
  region       = "asia-northeast3"

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-minimal-2404-lts-amd64"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
    access_config {
      # Public IP (NAT가 없으므로 필요)
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "Hello from $(hostname)" > /var/www/html/index.html
  EOF

  lifecycle {
    create_before_destroy = true
  }
}
```

### 2.3 `mig.tf` (Managed Instance Group)
템플릿을 기반으로 인스턴스 그룹을 생성하고 관리합니다.

```hcl
resource "google_compute_active_health_check" "default" {
  name               = "pista-hc-tf"
  check_interval_sec = 10
  timeout_sec        = 5
  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_region_instance_group_manager" "mig" {
  name               = "pista-mig-tf"
  base_instance_name = "pista-web"
  region             = "asia-northeast3"
  target_size        = var.mig_size

  version {
    instance_template = google_compute_instance_template.template.id
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_active_health_check.default.id
    initial_delay_sec = 300
  }
}
```

### 2.4 `load_balancer.tf`
HTTP Load Balancer의 5가지 구성 요소(Backend, URL Map, Proxy, IP, Rule)를 정의합니다.

```hcl
# 1. Backend Service
resource "google_compute_backend_service" "backend" {
  name                  = "pista-backend-tf"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_active_health_check.default.id]

  backend {
    group = google_compute_region_instance_group_manager.mig.instance_group
  }
}

# 2. URL Map
resource "google_compute_url_map" "default" {
  name            = "pista-url-map-tf"
  default_service = google_compute_backend_service.backend.id
}

# 3. Target HTTP Proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "pista-http-proxy-tf"
  url_map = google_compute_url_map.default.id
}

# 4. Global IP
resource "google_compute_global_address" "default" {
  name = "pista-lb-ip-tf"
}

# 5. Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "default" {
  name       = "pista-forwarding-rule-tf"
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"
  ip_address = google_compute_global_address.default.address
}
```

### 2.5 `outputs.tf` (추가)

```hcl
output "load_balancer_ip" {
  value = google_compute_global_address.default.address
}
```

---

## 3. 실행 및 검증

### 3.1 적용
```bash
terraform apply
```

### 3.2 테스트
출력된 LB IP로 접속합니다. (프로비저닝에 1~5분 소요될 수 있습니다)

```bash
curl http://<LOAD_BALANCER_IP>
```
여러 번 요청 시 "Hello from pista-web-xxxx" 호스트네임이 변경되는지 확인하여 로드밸런싱 동작을 검증합니다.

### 3.3 정리
```bash
terraform destroy
```
