# aws-basic1-1

Custom VPC에 Public/Private 이중 서브넷을 구성하고 EC2 인스턴스를 배포하는 실습입니다.
`default_tags`로 모든 리소스에 공통 태그를 적용합니다.

## 파일 구조

```
aws-basic1-1/
├── provider.tf     # CSP, 버전, 리전, default_tags 설정
├── provider.md     # provider.tf 문서
├── network.tf      # VPC, Public/Private 서브넷, IGW, EIP, NAT, 라우트 테이블
├── network.md      # network.tf 문서
├── main.tf         # EC2 인스턴스 리소스
├── main.md         # main.tf 문서
├── s3.tf           # S3 정적 웹사이트 호스팅
├── s3.md           # s3.tf 문서
└── index.html      # S3에 업로드할 정적 웹페이지
```

## 아키텍처

```
AWS (ap-southeast-1)
│
└── aws_vpc "pista-vpc-terraform"  (10.0.0.0/16)
    │
    ├── aws_internet_gateway "pista-igw"
    │
    ├── [Public Zone]
    │   ├── aws_subnet "pista-subnet"  (10.0.1.0/24, map_public_ip=true)
    │   │   ├── aws_nat_gateway "pista-nat"
    │   │   │   └── aws_eip "pista-nat-eip"
    │   │   └── aws_instance "name"  (t4g.micro)
    │   └── aws_route_table "pista-rt"
    │       ├── route: 0.0.0.0/0 → pista-igw
    │       └── aws_route_table_association "pista-rta"
    │
    └── [Private Zone]
        ├── aws_subnet "pista-private-subnet"  (10.0.2.0/24)
        └── aws_route_table "pista-private-rt"
            ├── route: 0.0.0.0/0 → pista-nat
            └── aws_route_table_association "pista-private-rta"

[S3 - Global Service]
└── aws_s3_bucket "pista-static"
    ├── aws_s3_bucket_public_access_block
    ├── aws_s3_bucket_website_configuration  (index.html)
    ├── aws_s3_bucket_policy  (PublicReadGetObject)
    └── aws_s3_object "index"  ← index.html
```

## 리소스 목록

| 리소스 | 이름 | 설명 |
|--------|------|------|
| `aws_vpc` | `pista-vpc-terraform` | VPC (10.0.0.0/16) |
| `aws_internet_gateway` | `pista-igw` | 인터넷 게이트웨이 |
| `aws_subnet` | `pista-subnet` | **Public** 서브넷 (10.0.1.0/24) |
| `aws_subnet` | `pista-private-subnet` | **Private** 서브넷 (10.0.2.0/24) |
| `aws_eip` | `pista-nat-eip` | NAT Gateway용 Elastic IP |
| `aws_nat_gateway` | `pista-nat` | NAT Gateway (Public Subnet 배치) |
| `aws_route_table` | `pista-rt` | Public RT (0.0.0.0/0 → IGW) |
| `aws_route_table_association` | `pista-rta` | Public Subnet ↔ Public RT |
| `aws_route_table` | `pista-private-rt` | Private RT (0.0.0.0/0 → NAT) |
| `aws_route_table_association` | `pista-private-rta` | Private Subnet ↔ Private RT |
| `aws_security_group` | `pista-sg` | EC2용 SSH/HTTP 인바운드 허용 |
| `aws_instance` | `name` | EC2 인스턴스 (ARM64, t4g.micro) |
| `random_id` | `suffix` | S3 버킷 이름 전역 유니크용 랜덤 접미사 |
| `aws_s3_bucket` | `pista-static` | S3 정적 웹사이트 버킷 |
| `aws_s3_bucket_website_configuration` | `pista-static` | 정적 웹호스팅 설정 (index.html) |
| `aws_s3_bucket_public_access_block` | `pista-static` | 퍼블릭 액세스 허용 |
| `aws_s3_bucket_policy` | `pista-static` | PublicReadGetObject 정책 |
| `aws_s3_object` | `index` | index.html 업로드 |

## default_tags (전체 리소스 공통)

| 키 | 값 |
|----|-----|
| `Username` | `pista` |
| `Team` | `team1` |
| `Project` | `MSP Last Project` |
| `Environment` | `Op` |

## 실행 순서

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

---

[Terraform MOC](../../Terraform_MOC.md)
