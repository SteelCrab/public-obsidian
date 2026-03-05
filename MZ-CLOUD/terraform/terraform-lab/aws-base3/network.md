# Terraform network.tf 설정

#terraform #network #aws #vpc #subnet #igw #nat #sg

---

`network.tf`는 ALB + ASG 실습용 네트워크(VPC, 퍼블릭/프라이빗 서브넷, IGW, NAT, 라우팅, 보안그룹)를 구성합니다.

## 구성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| `aws_vpc` | `pista-vpc-asg` | ASG 실습용 VPC (`10.30.0.0/16`) |
| `aws_subnet` | `pista-public-a/b` | ALB, NAT 배치용 퍼블릭 서브넷 |
| `aws_subnet` | `pista-private-a/b` | ASG 인스턴스 배치용 프라이빗 서브넷 |
| `aws_internet_gateway` | `pista-igw-asg` | 인터넷 게이트웨이 |
| `aws_eip` | `pista-nat-eip-asg` | NAT Gateway용 Elastic IP |
| `aws_nat_gateway` | `pista-nat-asg` | 프라이빗 아웃바운드용 NAT |
| `aws_route_table` | `pista-public-rt-asg` | 퍼블릭 라우트 테이블 |
| `aws_route_table` | `pista-private-rt-asg` | 프라이빗 라우트 테이블 |
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
