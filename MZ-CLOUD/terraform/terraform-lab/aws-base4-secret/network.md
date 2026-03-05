# Terraform network.tf 설정 (aws-base1-2)

#terraform #network #aws #vpc #subnet #igw #nat #eip #routetable #securitygroup

---

`network.tf`는 VPC, Public/Private 서브넷, IGW, EIP, NAT Gateway, 라우트 테이블, 보안그룹을 정의합니다.
`provider.tf`에서 선언한 AWS provider를 기반으로 네트워크를 구성합니다. → [[provider]] | [[locals]]

## 파일 구조

```hcl
# VPC
resource "aws_vpc" "main" { ... }

# Public Subnet (NAT Gateway 배치용)
resource "aws_subnet" "public" {
  map_public_ip_on_launch = true
  ...
}

# Private Subnet (EC2 배치)
resource "aws_subnet" "private" { ... }

# Internet Gateway
resource "aws_internet_gateway" "igw" { ... }

# Elastic IP (NAT Gateway용)
resource "aws_eip" "nat" {
  domain = "vpc"
}

# NAT Gateway (Public Subnet에 배치)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]
}

# Public Route Table (0.0.0.0/0 → IGW)
resource "aws_route_table" "public" { ... }
resource "aws_route_table_association" "public" { ... }

# Private Route Table (0.0.0.0/0 → NAT Gateway)
resource "aws_route_table" "private" { ... }
resource "aws_route_table_association" "private" { ... }

# Security Group
resource "aws_security_group" "ec2" { ... }
```

## aws_vpc 블록

| 항목 | 설명 |
|------|------|
| `cidr_block` | VPC의 IP 주소 범위 (`var.vpc_cidr`) |
| `enable_dns_support` | VPC 내 DNS 확인 활성화 (기본값 true) |
| `enable_dns_hostnames` | 퍼블릭 IP를 가진 인스턴스에 DNS 호스트네임 할당 |

> `enable_dns_hostnames = true`는 `enable_dns_support = true`일 때만 동작합니다.

## aws_subnet 블록

| 항목 | 설명 |
|------|------|
| `vpc_id` | 소속 VPC 참조 |
| `cidr_block` | 서브넷 IP 범위 |
| `map_public_ip_on_launch` | `true` → Public Subnet (자동 퍼블릭 IP 할당) |

| 서브넷 | CIDR | 타입 | 용도 |
|--------|------|------|------|
| `public` | `var.public_subnet_cidr` (`10.0.1.0/24`) | Public | NAT Gateway 배치 |
| `private` | `var.private_subnet_cidr` (`10.0.2.0/24`) | Private | EC2 배치 |

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
| `public` (Public) | `0.0.0.0/0` | `igw` |
| `private` (Private) | `0.0.0.0/0` | `nat` |

## aws_security_group 블록

| 항목 | 설명 |
|------|------|
| `name` | 보안그룹 이름 (`local.service_name-sg`) |
| `vpc_id` | 소속 VPC 참조 |
| `ingress` | 인바운드 규칙 |
| `egress` | 아웃바운드 규칙 |

### 인바운드 규칙

| 포트 | 프로토콜 | 소스 | 설명 |
|------|----------|------|------|
| 22 | TCP | `var.vpc_cidr` (`10.0.0.0/16`) | SSH (**VPC 내부만 허용**) |

### 아웃바운드 규칙

| 포트 | 프로토콜 | 대상 | 설명 |
|------|----------|------|------|
| 전체 | -1 (all) | 0.0.0.0/0 | 모든 트래픽 허용 |

> aws-basic1과 차이: SSH 소스가 `0.0.0.0/0`(전체)이 아닌 `var.vpc_cidr`(VPC 내부)로 제한됩니다.
> EC2가 Private Subnet에 있으므로 Bastion Host나 VPN을 통한 VPC 내부 접근만 허용합니다.

## 리소스 의존 관계

```
aws_vpc
├── aws_subnet (public)  ←── aws_route_table_association (public)
│   └── aws_nat_gateway  ←── aws_eip
│       └── depends_on: aws_internet_gateway
├── aws_subnet (private) ←── aws_route_table_association (private)
├── aws_internet_gateway
│   └── aws_route_table (public) → route: 0.0.0.0/0 → igw
├── aws_route_table (private)    → route: 0.0.0.0/0 → nat
└── aws_security_group (ec2)
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
