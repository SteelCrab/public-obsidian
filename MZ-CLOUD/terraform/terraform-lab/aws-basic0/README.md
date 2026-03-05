# aws-basic0

AWS Default VPC에 EC2 인스턴스를 배포하는 기초 실습입니다.

## 파일 구조

```
aws-basic0/
├── provider.tf     # CSP, 버전, 리전 설정
├── provider.md     # provider.tf 문서
├── main.tf         # EC2 인스턴스 리소스
└── main.md         # main.tf 문서
```

## 아키텍처

```
AWS (ap-southeast-1)
│
└── Default VPC
    │
    └── aws_instance "name"
        ├── ami           : ami-054240677cb44ffac (Ubuntu 24.04 LTS, ARM64)
        ├── instance_type : t3.micro
        └── tags
            └── Name : pista-test-ec2
```

## 리소스 목록

| 리소스 | 이름 | 설명 |
|--------|------|------|
| `aws_instance` | `name` | EC2 인스턴스 (Default VPC) |

## 실행 순서

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

---

[Terraform MOC](../../Terraform_MOC.md)
