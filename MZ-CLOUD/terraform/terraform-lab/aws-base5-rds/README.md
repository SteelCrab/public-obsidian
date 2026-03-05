# aws-base5-rds

RDS 구축을 위한 네트워크 + Bastion + RDS 실습 구성. (2026-02-23)

## 아키텍처

```
Internet
    │
[IGW: pista-igw]
    │
[public-a: 10.50.3.0/24]  ← Bastion (pista-bastion) + NAT Gateway
    │
    ├── [private-a: 10.50.13.0/24]  앱 서버 (AZ-a)  ─┐
    │                                                   ├→ NAT → Internet
    └── [private-b: 10.50.14.0/24]  앱 서버 (AZ-b)  ─┘

[private-rds-a: 10.50.21.0/24]  RDS 전용 (local only)  ─┐ DB Subnet Group
[private-rds-b: 10.50.22.0/24]  RDS 전용 (local only)  ─┘
         ↑ pista-rds (MySQL 8.0, db.t3.micro)
```

## 파일 구성

| 파일 | 설명 | 문서 |
|------|------|------|
| `provider.tf` | AWS provider, 리전, default_tags | — |
| `network.tf` | VPC, 서브넷 5개, RTB 3개, RDS SG | [[network]] |
| `bastion.tf` | 키페어, Bastion SG, EC2 | [[bastion]] |
| `bastion-init.sh` | Bastion 초기화 스크립트 | — |
| `rds.tf` | DB Subnet Group, RDS 인스턴스 | [[rds]] |

## 리소스 목록

| 리소스 | Name 태그 | CIDR / 비고 |
|--------|-----------|-------------|
| VPC | `pista-vpc` | 10.50.0.0/16 |
| IGW | `pista-igw` | — |
| EIP | `pista-nat-eip` | — |
| NAT GW | `pista-nat` | public-a 배치 |
| Subnet | `pista-public-a` | 10.50.3.0/24, AZ-a |
| Subnet | `pista-private-a` | 10.50.13.0/24, AZ-a |
| Subnet | `pista-private-b` | 10.50.14.0/24, AZ-b |
| Subnet | `pista-private-rds-a` | 10.50.21.0/24, AZ-a |
| Subnet | `pista-private-rds-b` | 10.50.22.0/24, AZ-b |
| Route Table | `pista-public-rt` | → IGW |
| Route Table | `pista-private-rt` | → NAT (private-a, b 공유) |
| Route Table | `pista-private-rds-rt` | local only (rds-a, b 공유) |
| Security Group | `pista-rds-sg` | MySQL 3306, private-a/b에서만 |
| Security Group | `pista-bastion-sg` | SSH 22, 인터넷 허용 |
| Key Pair | `pista-key` | ~/.ssh/pista-key.pub |
| EC2 | `pista-bastion` | t4g.micro, public-a |
| DB Subnet Group | `pista-rds-subnet-group` | rds-a, rds-b |
| RDS | `pista-rds` | MySQL 8.0, db.t3.micro, 20GB |

## 실행

```bash
# 1. 키페어 생성 (최초 1회)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/pista-key

# 2. 초기화 및 검증
terraform init
terraform validate
terraform plan -var="db_password=MyPassword123!"

# 3. 배포
terraform apply -var="db_password=MyPassword123!"

# 4. 접속 확인
ssh -i ~/.ssh/pista-key ubuntu@$(terraform output -raw bastion_public_ip)

# 5. 정리
terraform destroy -var="db_password=MyPassword123!"
```
