# aws-base2

AWS ALB(Application Load Balancer) 기반으로 2대의 EC2 웹 서버를 라우팅하는 실습입니다.

## 파일 구조

```text
aws-base2/
├── provider.tf   # AWS provider, 버전, 리전, default_tags
├── provider.md   # provider.tf 문서
├── network.tf    # VPC, Subnet, IGW, Route Table, Security Group
├── network.md    # network.tf 문서
├── main.tf       # EC2 웹 서버 2대
├── main.md       # main.tf 문서
├── alb.tf        # ALB, Target Group, Listener, Attachment, Output
└── alb.md        # alb.tf 문서
```

## 아키텍처

```text
Internet
  -> ALB (pista-alb :80)
      -> Target Group (pista-tg)
          -> EC2 pista-web-a (private-a)
          -> EC2 pista-web-b (private-b)

Public Subnet:
  - ALB
  - NAT Gateway

Private Subnet:
  - EC2 Web Servers
```

## 실행 순서

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform output alb_dns_name
terraform destroy
```

---

[Terraform MOC](../../Terraform_MOC.md)
