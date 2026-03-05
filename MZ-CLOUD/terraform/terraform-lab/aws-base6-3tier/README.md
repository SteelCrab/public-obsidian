# aws-base6-3tier

3-Tier 아키텍처 실습: ALB + ASG(nginx/fastAPI) + RDS(Primary/Replica). (2026-02-24)

## 아키텍처

```
Internet
    │
[ALB: pista-alb] ← pista-alb-sg (HTTP 80, HTTPS 443)
    │  (public-a/b/c)
    │
[nginx:80] ──→ [fastAPI:8000]     ← pista-app (t3.micro, private-a/b/c)
   ASG min=1 / desired=1 / max=2
    │
[RDS Primary: pista-rds-primary]  ← pista-private-db-a (local only)
[RDS Replica: pista-rds-replica]  ← pista-private-db-b (local only)

[Bastion: pista-bastion] ← t3.nano, public-b (2번째 퍼블릭 서브넷)
```

## 서브넷 설계 (ap-southeast-1, 3개 AZ)

| 서브넷 | CIDR | AZ | RTB |
|--------|------|----|-----|
| `pista-public-a` | 10.0.1.0/24 | AZ-a | → IGW |
| `pista-public-b` | 10.0.2.0/24 | AZ-b | → IGW |
| `pista-public-c` | 10.0.3.0/24 | AZ-c | → IGW |
| `pista-private-a` | 10.0.11.0/24 | AZ-a | → NAT |
| `pista-private-b` | 10.0.12.0/24 | AZ-b | → NAT |
| `pista-private-c` | 10.0.13.0/24 | AZ-c | → NAT |
| `pista-private-db-a` | 10.0.21.0/24 | AZ-a | local only |
| `pista-private-db-b` | 10.0.22.0/24 | AZ-b | local only |
| `pista-private-db-c` | 10.0.23.0/24 | AZ-c | local only |

## 보안그룹 흐름

```
Internet → pista-alb-sg (80, 443)
         → pista-nginx-sg (80 from alb-sg)
           → pista-fastapi-sg (8000 from nginx-sg)
             → pista-db-sg (3306 from fastapi-sg)

Internet → pista-bastion-sg (22)
         → pista-db-sg (3306 from bastion-sg)  # DB 직접 관리
         → pista-nginx-sg (22 from bastion-sg) # 앱 서버 SSH
```

## 파일 구성

| 파일 | 설명 |
|------|------|
| `provider.tf` | terraform block (S3 backend), AWS provider |
| `network.tf` | VPC, 9개 서브넷, RTB 3개, IGW, NAT GW |
| `sg.tf` | 5개 보안그룹 (alb, bastion, nginx, fastapi, db) |
| `bastion.tf` | 키페어, Bastion EC2 (public-b, t3.nano) |
| `bastion-init.sh` | mysql-client, AWS CLI 설치 |
| `rds.tf` | DB Subnet Group, RDS Primary/Replica (MySQL 8.0, db.t3.micro) |
| `asg.tf` | ALB, Target Group, Launch Template, ASG (t3.micro, min1/des1/max2) |
| `app-init.sh` | nginx + fastAPI 설치 및 systemd 설정 |

## S3 Backend 사전 준비 (팀 공유)

```bash
# S3 버킷 생성 (versioning + 암호화)
aws s3api create-bucket \
  --bucket pista-tf-state-bucket \
  --region ap-southeast-1 \
  --create-bucket-configuration LocationConstraint=ap-southeast-1

aws s3api put-bucket-versioning \
  --bucket pista-tf-state-bucket \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket pista-tf-state-bucket \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
```

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

# 4. 결과 확인
terraform output alb_dns_name
terraform output bastion_public_ip

# 5. 정리
terraform destroy -var="db_password=MyPassword123!"
```
