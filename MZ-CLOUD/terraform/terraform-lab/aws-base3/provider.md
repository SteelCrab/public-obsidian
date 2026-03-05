# Terraform provider.tf 설정

#terraform #provider #aws #버전 #리전 #default_tags

---

`provider.tf`는 AWS provider 버전, 리전, 공통 태그를 정의합니다.

| 항목 | 값 |
|------|----|
| Provider | `hashicorp/aws` |
| Version | `~> 5.0` |
| Region | `ap-southeast-1` |

## 핵심 포인트

| 설정 | 설명 |
|------|------|
| `required_providers` | 사용할 provider 소스/버전 고정 |
| `provider "aws"` | 리전 및 인증 컨텍스트 지정 |
| `default_tags` | 모든 리소스에 공통 태그 자동 적용 |

## default_tags

| 태그 키 | 값 |
|---------|-----|
| `Username` | `pista` |
| `Team` | `team1` |
| `Project` | `MSP Last Project` |
| `Environment` | `Op` |

## 실행 방법

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

---

[Terraform MOC](../../Terraform_MOC.md)
