# Terraform 리소스 유형 (AWS vs GCP)

#terraform #aws #gcp #리소스

---

AWS와 GCP의 주요 Terraform 리소스 유형 비교표입니다.

## 주요 리소스 유형 비교

| 카테고리 | AWS 리소스 유형 | GCP 리소스 유형 | 설명 |
|----------|----------------|----------------|------|
| 가상 서버 | `aws_instance` | `google_compute_instance` | EC2 / VM |
| 네트워크 | `aws_vpc` | `google_compute_network` | VPC |
| 서브넷 | `aws_subnet` | `google_compute_subnetwork` | 서브넷 |
| 보안/방화벽 | `aws_security_group` | `google_compute_firewall` | 보안 규칙 |
| 객체 스토리지 | `aws_s3_bucket` | `google_storage_bucket` | S3 / GCS |
| 데이터베이스 | `aws_db_instance` | `google_sql_database_instance` | RDS / Cloud SQL |
| 로드밸런서 | `aws_lb` | `google_compute_forwarding_rule` | ALB/NLB |
| 대상 그룹 | `aws_lb_target_group` | `google_compute_backend_service` | 백엔드 서비스 |
| 오토스케일링 | `aws_autoscaling_group` | `google_compute_instance_group_manager` | ASG / MIG |
| 시작 템플릿 | `aws_launch_template` | `google_compute_instance_template` | 인스턴스 템플릿 |
| 공인 IP | `aws_eip` | `google_compute_address` | 고정 공인 IP |

## 참고

- AWS Provider: `hashicorp/aws`
- GCP Provider: `hashicorp/google`
- 리소스 이름 패턴: AWS는 `aws_*`, GCP는 `google_*` 접두사 사용

[Terraform MOC](./Terraform_MOC.md)
