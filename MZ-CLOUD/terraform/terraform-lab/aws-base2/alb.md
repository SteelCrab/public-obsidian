# Terraform alb.tf 설정

#terraform #alb #aws #target-group #listener

---

`alb.tf`는 인터넷 공개형 ALB, 타겟 그룹, 리스너, EC2 타겟 연결을 정의합니다.

## 구성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| `aws_lb` | `pista-alb` | 인터넷-facing ALB |
| `aws_lb_target_group` | `pista-tg` | EC2 대상 HTTP 타겟 그룹 |
| `aws_lb_listener` | `pista-http` | 80 포트 리스너 |
| `aws_lb_target_group_attachment` | `pista-web-a/b` | 각 EC2를 타겟으로 등록 |
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

[[main]]
[Terraform MOC](../../Terraform_MOC.md)
