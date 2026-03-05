# Terraform main.tf 설정

#terraform #main #aws #ec2 #nginx

---

`main.tf`는 ALB 뒤에서 동작할 EC2 웹 서버 2대를 프라이빗 서브넷에 생성합니다.

## 구성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| `aws_instance` | `pista-web-a` | AZ-a에 배치되는 Nginx 웹 서버 |
| `aws_instance` | `pista-web-b` | AZ-b에 배치되는 Nginx 웹 서버 |

## 주요 설정

| 항목 | 값 |
|------|----|
| `ami` | `ami-054240677cb44ffac` (ARM64) |
| `instance_type` | `t4g.micro` |
| `subnet_id` | `pista-private-a`, `pista-private-b` |
| `vpc_security_group_ids` | `pista-web-sg` |
| `user_data` | Nginx 설치 + index.html 생성 |

## 실행 방법

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

---

[[network]]
[Terraform MOC](../../Terraform_MOC.md)
