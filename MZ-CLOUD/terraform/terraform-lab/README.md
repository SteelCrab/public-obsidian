# Terraform Lab

#terraform #aws #실습 #lab

---

AWS 인프라를 Terraform으로 구축하는 단계별 실습 모음입니다.
기초 EC2 배포부터 ALB + Auto Scaling 아키텍처까지 순차적으로 학습합니다.

## 실습 목록

| 디렉토리 | 주요 개념 | 설명 |
|----------|-----------|------|
| `aws-basic0` | provider, EC2 | AWS Default VPC에 EC2 배포 (최소 구성) |
| `aws-basic1-1` | VPC, Public EC2, S3 | Custom VPC + Public Subnet EC2 + S3 정적 웹사이트 |
| `aws-base1-2` | variables, locals, Private EC2 | 변수 분리 + Private Subnet EC2 + NAT Gateway |
| `aws-base2` | ALB, Target Group | ALB로 Private EC2 웹 서버 2대 라우팅 |
| `aws-base3` | ALB, ASG | ALB + Auto Scaling Group 자동 확장 |

## 학습 진행 순서

```
aws-basic0
  └── EC2 기초 배포 (Default VPC)
       ↓
aws-basic1-1
  └── Custom VPC + Public EC2 + S3
       ↓
aws-base1-2
  └── variables/locals 분리 + Private EC2 + NAT
       ↓
aws-base2
  └── ALB + Private EC2 2대
       ↓
aws-base3
  └── ALB + Auto Scaling Group
```

## 디렉토리 구조

```
terraform-lab/
├── aws-basic0/       # EC2 기초 (provider + main)
├── aws-basic1-1/     # Custom VPC + Public EC2 + S3
├── aws-base1-2/      # variables + locals + Private EC2
├── aws-base2/        # ALB + EC2 웹 서버 2대
└── aws-base3/        # ALB + ASG 자동 확장
```

## 공통 실행 명령어

```bash
terraform init       # provider 플러그인 설치
terraform fmt -recursive  # 코드 포맷 정리
terraform validate   # 문법 유효성 검사
terraform plan       # 변경 사항 미리 확인
terraform apply      # 리소스 배포
terraform destroy    # 리소스 삭제
```

---

[Terraform MOC](../Terraform_MOC.md)
