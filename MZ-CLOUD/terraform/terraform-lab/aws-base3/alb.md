# Terraform alb.tf 설정

#terraform #alb #aws #target-group #listener

---

`alb.tf`는 인터넷 공개형 ALB, 타겟 그룹, 리스너를 정의합니다.
백엔드 타겟 등록은 `asg.tf`의 Auto Scaling Group 연결로 처리됩니다.

## 구성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| `aws_lb` | `pista-alb-asg` | 인터넷-facing ALB |
| `aws_lb_target_group` | `pista-tg-asg` | ASG 인스턴스 대상 HTTP 타겟 그룹 |
| `aws_lb_listener` | `pista-http` | 80 포트 리스너 |
| `output` | `alb_dns_name` | 접속용 ALB DNS 출력 |

## 헬스체크

| 항목 | 값 |
|------|----|
| Path | `/` |
| Matcher | `200` |
| Interval | `30` |
| Healthy Threshold | `2` |
| Unhealthy Threshold | `2` |

## 실행 방법

```bash
terraform init
terraform plan
terraform apply
terraform output alb_dns_name
terraform destroy
```

---

[[asg]]
[Terraform MOC](../../Terraform_MOC.md)
