# aws-base3

AWS ALB + Auto Scaling Group 기반으로 프라이빗 서브넷의 웹 서버를 자동 확장하는 실습입니다.

## 파일 구조

```text
aws-base3/
├── provider.tf   # AWS provider, 버전, 리전, default_tags
├── provider.md   # provider.tf 문서
├── network.tf    # VPC, Public/Private Subnet, IGW, NAT, Route Table, SG
├── network.md    # network.tf 문서
├── alb.tf        # ALB, Target Group, Listener, ALB DNS output
├── alb.md        # alb.tf 문서
├── asg.tf        # Launch Template, ASG, Auto Scaling Policy, ASG output
└── asg.md        # asg.tf 문서
```

## 아키텍처

```text
Internet
  -> ALB (pista-alb-asg :80)
      -> Target Group (pista-tg-asg)
          -> ASG instances (private-a/private-b)

Public Subnet:
  - ALB
  - NAT Gateway

Private Subnet:
  - Auto Scaling EC2 instances
```

## 실행 순서

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform output alb_dns_name
terraform output autoscaling_group_name
terraform destroy
```

---

[Terraform MOC](../../Terraform_MOC.md)
