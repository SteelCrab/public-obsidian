# Terraform network.tf 설정

#terraform #network #aws #vpc #subnet #igw #nat #eip #routetable

---

`network.tf`는 VPC, Public/Private 서브넷, IGW, EIP, NAT Gateway, 라우트 테이블을 정의합니다.
`provider.tf`에서 선언한 CSP(AWS)를 기반으로 네트워크를 구성합니다. → [[provider]]

## 파일 구조

```hcl
# VPC
resource "aws_vpc" "pista-vpc-terraform" { ... }

# Public Subnet
resource "aws_subnet" "pista-subnet" {
  map_public_ip_on_launch = true
  ...
}

# Private Subnet
resource "aws_subnet" "pista-private-subnet" { ... }

# Internet Gateway
resource "aws_internet_gateway" "pista-igw" { ... }

# Public Route Table (0.0.0.0/0 → IGW)
resource "aws_route_table" "pista-rt" { ... }
resource "aws_route_table_association" "pista-rta" { ... }

# Elastic IP (NAT Gateway용)
resource "aws_eip" "pista-nat-eip" {
  domain = "vpc"
}

# NAT Gateway (Public Subnet에 배치)
resource "aws_nat_gateway" "pista-nat" {
  allocation_id = aws_eip.pista-nat-eip.id
  subnet_id     = aws_subnet.pista-subnet.id
  depends_on    = [aws_internet_gateway.pista-igw]
}

# Private Route Table (0.0.0.0/0 → NAT Gateway)
resource "aws_route_table" "pista-private-rt" { ... }
resource "aws_route_table_association" "pista-private-rta" { ... }
```

## aws_vpc 블록

| 항목 | 설명 |
|------|------|
| `cidr_block` | VPC의 IP 주소 범위 |
| `enable_dns_support` | VPC 내 DNS 확인 활성화 (기본값 true) |
| `enable_dns_hostnames` | 퍼블릭 IP를 가진 인스턴스에 DNS 호스트네임 할당 |

> `enable_dns_hostnames = true`는 `enable_dns_support = true`일 때만 동작합니다.

## aws_subnet 블록

| 항목 | 설명 |
|------|------|
| `vpc_id` | 소속 VPC 참조 |
| `cidr_block` | 서브넷 IP 범위 |
| `map_public_ip_on_launch` | `true` → Public Subnet (자동 퍼블릭 IP) |

| 서브넷 | CIDR | 타입 |
|--------|------|------|
| `pista-subnet` | `10.0.1.0/24` | Public |
| `pista-private-subnet` | `10.0.2.0/24` | Private |

## aws_internet_gateway 블록

| 항목 | 설명 |
|------|------|
| `vpc_id` | 연결할 VPC 참조 |

## aws_eip 블록

| 항목 | 설명 |
|------|------|
| `domain` | `"vpc"` - VPC 내 사용할 Elastic IP |

> NAT Gateway에 고정 퍼블릭 IP를 할당합니다.

## aws_nat_gateway 블록

| 항목 | 설명 |
|------|------|
| `allocation_id` | 연결할 EIP 참조 |
| `subnet_id` | NAT Gateway를 배치할 **Public** 서브넷 |
| `depends_on` | IGW가 먼저 생성되어야 함을 명시 |

> Private Subnet의 인스턴스가 인터넷으로 아웃바운드 트래픽을 보낼 수 있게 합니다.
> NAT Gateway는 반드시 **Public Subnet**에 위치해야 합니다.

## aws_route_table 블록

| 라우트 테이블 | 대상 | 게이트웨이 |
|--------------|------|-----------|
| `pista-rt` (Public) | `0.0.0.0/0` | `pista-igw` |
| `pista-private-rt` (Private) | `0.0.0.0/0` | `pista-nat` |

## aws_security_group 블록

| 항목 | 설명 |
|------|------|
| `name` | 보안그룹 이름 |
| `vpc_id` | 소속 VPC 참조 |
| `ingress` | 인바운드 규칙 |
| `egress` | 아웃바운드 규칙 |

### 인바운드 규칙

| 포트 | 프로토콜 | 소스 | 설명 |
|------|----------|------|------|
| 22 | TCP | 0.0.0.0/0 | SSH |
| 80 | TCP | 0.0.0.0/0 | HTTP |

### 아웃바운드 규칙

| 포트 | 프로토콜 | 대상 | 설명 |
|------|----------|------|------|
| 전체 | -1 (all) | 0.0.0.0/0 | 모든 트래픽 허용 |

## 리소스 의존 관계

```
aws_vpc
├── aws_subnet (public)  ←── aws_route_table_association (pista-rta)
│   └── aws_nat_gateway ←── aws_eip
├── aws_subnet (private) ←── aws_route_table_association (pista-private-rta)
├── aws_internet_gateway
│   └── aws_route_table (public)
└── aws_route_table (private) ←── aws_nat_gateway
```

## 실행 방법

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

---

[Terraform MOC](../../Terraform_MOC.md)
