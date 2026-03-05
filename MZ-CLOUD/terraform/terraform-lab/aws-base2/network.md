# Terraform network.tf 설정

#terraform #network #aws #vpc #subnet #igw #sg

---

`network.tf`는 ALB 실습용 네트워크(VPC, 퍼블릭/프라이빗 서브넷, IGW, NAT, 라우팅, 보안그룹)를 구성합니다.

## 구성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| `aws_vpc` | `pista-vpc-alb` | ALB 실습용 VPC (`10.20.0.0/16`) |
| `aws_subnet` | `pista-public-a` | AZ-a 퍼블릭 서브넷 (`10.20.1.0/24`) |
| `aws_subnet` | `pista-public-b` | AZ-b 퍼블릭 서브넷 (`10.20.2.0/24`) |
| `aws_subnet` | `pista-private-a` | AZ-a 프라이빗 서브넷 (`10.20.11.0/24`) |
| `aws_subnet` | `pista-private-b` | AZ-b 프라이빗 서브넷 (`10.20.12.0/24`) |
| `aws_internet_gateway` | `pista-igw-alb` | 인터넷 게이트웨이 |
| `aws_route_table` | `pista-public-rt-alb` | 퍼블릭 라우트 테이블 |
| `aws_eip` | `pista-nat-eip-alb` | NAT Gateway용 Elastic IP |
| `aws_nat_gateway` | `pista-nat-alb` | 프라이빗 서브넷 아웃바운드용 NAT |
| `aws_route_table` | `pista-private-rt-alb` | 프라이빗 라우트 테이블 |
| `aws_security_group` | `pista-alb-sg` | ALB용 HTTP/HTTPS 허용 |
| `aws_security_group` | `pista-web-sg` | EC2용 HTTP(ALB/VPC), ICMP/SSH(VPC) 허용 |

## 보안 설계

| 보안그룹 | 인바운드 | 아웃바운드 |
|----------|----------|------------|
| `pista-alb-sg` | `0.0.0.0/0` -> `80,443/tcp` | 전체 허용 |
| `pista-web-sg` | `pista-alb-sg` -> `80/tcp`, `VPC CIDR` -> `80/tcp,22/tcp,ICMP` | 전체 허용 |

## 실행 방법

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

---

[[provider]]
[Terraform MOC](../../Terraform_MOC.md)
