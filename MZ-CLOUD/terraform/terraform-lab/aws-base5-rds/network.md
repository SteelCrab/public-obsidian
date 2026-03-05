# Terraform network.tf 설정 (aws-base5-rds)

#terraform #network #aws #vpc #subnet #nat #rds #격리서브넷

---

`network.tf`는 RDS 실습을 위한 VPC, 퍼블릭/프라이빗/RDS 전용 서브넷, IGW, NAT Gateway, 라우트 테이블, 보안그룹을 정의합니다.
기존 base2/base3 패턴에 **RDS 전용 격리 서브넷**을 추가한 구성입니다.

> 관련 문서: [[bastion]], [[rds]]

## 서브넷 설계

| 서브넷 | Name | CIDR | AZ | RTB |
|--------|------|------|----|-----|
| 퍼블릭 | `pista-public-a` | 10.50.3.0/24 | ap-southeast-1a | → IGW |
| 프라이빗 앱 (a) | `pista-private-a` | 10.50.13.0/24 | ap-southeast-1a | → NAT (공유) |
| 프라이빗 앱 (b) | `pista-private-b` | 10.50.14.0/24 | ap-southeast-1b | → NAT (공유) |
| RDS 전용 (a) | `pista-private-rds-a` | 10.50.21.0/24 | ap-southeast-1a | local only |
| RDS 전용 (b) | `pista-private-rds-b` | 10.50.22.0/24 | ap-southeast-1b | local only |

> RDS 서브넷 2개(a/b)는 DB Subnet Group에 **2개 이상의 AZ** 서브넷이 필요하기 때문입니다.

## 라우트 테이블 구조

| Route Table | 연결 서브넷 | Default Route |
|-------------|------------|---------------|
| `pista-public-rt` | public-a | 0.0.0.0/0 → IGW |
| `pista-private-rt` | private-a, private-b | 0.0.0.0/0 → NAT |
| `pista-private-rds-rt` | private-rds-a, private-rds-b | **없음** (local only) |

## aws_vpc 블록

| 항목 | 설명 |
|------|------|
| `cidr_block` | `10.50.0.0/16` |
| `enable_dns_support` | VPC 내 DNS 확인 활성화 |
| `enable_dns_hostnames` | 퍼블릭 IP 인스턴스에 DNS 호스트네임 부여 |

## aws_nat_gateway 블록

| 항목 | 설명 |
|------|------|
| `allocation_id` | EIP 참조 (`pista-nat-eip`) |
| `subnet_id` | 퍼블릭 서브넷 (`pista-public-a`) 배치 |
| `depends_on` | IGW 먼저 생성 명시 |

> private-a, private-b가 **동일한** `pista-private-rt`를 공유하여 NAT를 통해 인터넷 접근

## aws_security_group (RDS용)

| 방향 | 포트 | 소스 | 설명 |
|------|------|------|------|
| Inbound | 3306 (TCP) | 10.50.13.0/24 | private-a → RDS |
| Inbound | 3306 (TCP) | 10.50.14.0/24 | private-b → RDS |
| Outbound | 전체 | 0.0.0.0/0 | 모든 아웃바운드 허용 |

## 리소스 의존 관계

```
aws_vpc (pista-vpc)
├── aws_internet_gateway (pista-igw)
├── aws_eip (pista-nat-eip)
│   └── aws_nat_gateway (pista-nat) ← public-a 배치
│       └── depends_on: igw
├── public-a  → pista-public-rt  (→ IGW)
├── private-a → pista-private-rt (→ NAT)
├── private-b → pista-private-rt (→ NAT)
├── private-rds-a → pista-private-rds-rt (local only)
├── private-rds-b → pista-private-rds-rt (local only)
└── aws_security_group (pista-rds-sg)
```

---

[Terraform MOC](../../Terraform_MOC.md)
