# Terraform asg.tf 설정

#terraform #asg #autoscaling #launch-template #aws

---

`asg.tf`는 Launch Template, Auto Scaling Group, CPU 타겟 추적 정책을 정의합니다.

## 구성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| `aws_launch_template` | `pista-web-lt` | ASG 인스턴스 템플릿 |
| `aws_autoscaling_group` | `pista-web-asg` | 프라이빗 서브넷 기반 Auto Scaling 그룹 |
| `aws_autoscaling_policy` | `pista-web-cpu-tt` | CPU 60% 타겟 추적 정책 |
| `output` | `autoscaling_group_name` | ASG 이름 출력 |

## Launch Template 설정

| 항목 | 값 |
|------|----|
| `image_id` | `ami-054240677cb44ffac` (ARM64) |
| `instance_type` | `t4g.micro` |
| `vpc_security_group_ids` | `pista-web-sg` |
| `user_data` | Nginx 설치 + Instance ID를 index.html에 출력 |

## 기본 용량 설정

| 항목 | 값 |
|------|----|
| `min_size` | `1` |
| `desired_capacity` | `1` |
| `max_size` | `3` |

## ASG 추가 설정

| 항목 | 값 | 설명 |
|------|----|------|
| `health_check_type` | `ELB` | ALB 헬스체크 기반 인스턴스 교체 |
| `health_check_grace_period` | `180` | 인스턴스 시작 후 헬스체크 유예 시간(초) |
| `force_delete` | `true` | ASG 삭제 시 인스턴스 강제 종료 |

## 실행 방법

```bash
terraform init
terraform plan
terraform apply
terraform output autoscaling_group_name
terraform destroy
```

---

[[alb]]
[Terraform MOC](../../Terraform_MOC.md)
