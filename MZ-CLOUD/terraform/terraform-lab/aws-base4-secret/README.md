# aws-base1-2

#terraform #aws #vpc #ec2 #nat #variables #locals #private-subnet

---

`variables.tf` + `locals.tf`로 변수를 분리하고, EC2를 **Private Subnet**에 배치하는 실습입니다.
`local.service_name`으로 모든 리소스 이름을 동적으로 생성합니다.

## 파일 구조

```
aws-base1-2/
├── provider.tf     # CSP, 버전, 리전, default_tags(locals 참조)
├── provider.md
├── variables.tf    # 변수 선언 (region, team, worker, cidr 등)
├── variables.md
├── locals.tf       # service_name 조합, common_tags 정의
├── locals.md
├── network.tf      # VPC, Public/Private 서브넷, IGW, EIP, NAT, RT, SG
├── network.md
├── compute.tf      # EC2 (Private Subnet 배치)
└── compute.md
```

## 아키텍처

```
AWS (ap-southeast-1)
│
└── aws_vpc "main"  →  pista-worker-ec2-vpc  (10.0.0.0/16)
    │
    ├── aws_internet_gateway "igw"  →  pista-worker-ec2-igw
    │
    ├── [Public Zone]
    │   ├── aws_subnet "public"  →  pista-worker-ec2-public-subnet  (10.0.1.0/24)
    │   │   └── aws_nat_gateway "nat"  →  pista-worker-ec2-nat
    │   │       └── aws_eip "nat"  →  pista-worker-ec2-nat-eip
    │   └── aws_route_table "public"  →  pista-worker-ec2-public-rt
    │       ├── route: 0.0.0.0/0 → igw
    │       └── aws_route_table_association "public"
    │
    └── [Private Zone]
        ├── aws_subnet "private"  →  pista-worker-ec2-private-subnet  (10.0.2.0/24)
        │   └── aws_instance "main"  →  pista-worker-ec2  (t3.micro)
        ├── aws_security_group "ec2"  →  pista-worker-ec2-sg
        └── aws_route_table "private"  →  pista-worker-ec2-private-rt
            ├── route: 0.0.0.0/0 → nat
            └── aws_route_table_association "private"
```

## 리소스 목록

| 리소스 | 이름 (service_name 기반) | 설명 |
|--------|--------------------------|------|
| `aws_vpc` | `pista-worker-ec2-vpc` | VPC (10.0.0.0/16) |
| `aws_internet_gateway` | `pista-worker-ec2-igw` | 인터넷 게이트웨이 |
| `aws_subnet` (public) | `pista-worker-ec2-public-subnet` | **Public** 서브넷 (10.0.1.0/24) |
| `aws_subnet` (private) | `pista-worker-ec2-private-subnet` | **Private** 서브넷 (10.0.2.0/24) |
| `aws_eip` | `pista-worker-ec2-nat-eip` | NAT Gateway용 Elastic IP |
| `aws_nat_gateway` | `pista-worker-ec2-nat` | NAT Gateway (Public Subnet 배치) |
| `aws_route_table` (public) | `pista-worker-ec2-public-rt` | Public RT (0.0.0.0/0 → IGW) |
| `aws_route_table_association` (public) | — | Public Subnet ↔ Public RT |
| `aws_route_table` (private) | `pista-worker-ec2-private-rt` | Private RT (0.0.0.0/0 → NAT) |
| `aws_route_table_association` (private) | — | Private Subnet ↔ Private RT |
| `aws_security_group` | `pista-worker-ec2-sg` | EC2용 보안그룹 (SSH: VPC 내부만) |
| `aws_instance` | `pista-worker-ec2` | EC2 인스턴스 (x86, t3.micro) |

## common_tags (전체 리소스 공통)

| 태그 키 | 값 (기본값) | 설명 |
|---------|-------------|------|
| `Project_name` | `pista-worker-ec2` | `local.service_name` 동적 생성 |
| `Managed` | `Terraform` | IaC 관리 식별 |

## aws-basic1과의 차이점

| 항목 | aws-basic1 | aws-base1-2 |
|------|-----------|-------------|
| 태그 방식 | `default_tags`에 직접 하드코딩 | `locals.common_tags` 참조 |
| 변수 | 없음 (모두 하드코딩) | `variables.tf`로 분리 |
| EC2 배치 | Public Subnet | **Private Subnet** |
| user_data | nginx 설치 스크립트 포함 | 없음 (기본 배포) |
| S3 | S3 정적 웹사이트 포함 | 없음 |
| 리소스 이름 | 하드코딩 (`pista-*`) | `local.service_name` 동적 생성 |

## 실행 순서

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

---

[Terraform MOC](../../Terraform_MOC.md)
