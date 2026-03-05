# Terraform variables.tf 설정

#terraform #variables #변수 #aws #입력값

---

`variables.tf`는 Terraform 모듈의 입력 변수를 선언하는 파일입니다.
하드코딩 대신 변수로 분리하여 재사용성과 유지보수성을 높입니다. → [[locals]] | [[provider]]

## 파일 구조

```hcl
variable "region" {
  default = "ap-southeast-1"
}

variable "team" {
  default = "pista"
}

variable "worker" {
  default = "worker"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami" {
  # Ubuntu 24.04 LTS ap-southeast-1 (x86)
  default = "ami-08d59269edddde222"
}
```

## 변수 목록

| 변수명 | 타입 | 기본값 | 설명 |
|--------|------|--------|------|
| `region` | string | `ap-southeast-1` | 리소스를 배포할 AWS 리전 |
| `team` | string | `pista` | 팀명 (service_name 조합에 사용) |
| `worker` | string | `worker` | 워커명 (service_name 조합에 사용) |
| `vpc_cidr` | string | `10.0.0.0/16` | VPC IP 주소 범위 |
| `public_subnet_cidr` | string | `10.0.1.0/24` | Public 서브넷 IP 범위 |
| `private_subnet_cidr` | string | `10.0.2.0/24` | Private 서브넷 IP 범위 |
| `instance_type` | string | `t3.micro` | EC2 인스턴스 타입 |
| `ami` | string | `ami-08d59269edddde222` | Ubuntu 24.04 LTS (x86, ap-southeast-1) |

## 변수 참조 방법

| 참조 위치 | 표현식 | 예시 |
|-----------|--------|------|
| 리소스 내 | `var.<변수명>` | `var.region` |
| locals 내 | `var.<변수명>` | `${var.team}-${var.worker}-ec2` |
| 조건 | `var.<변수명> == "값"` | `var.region == "ap-southeast-1"` |

### 변수 활용 예시

```hcl
# provider.tf
region = var.region

# locals.tf
service_name = "${var.team}-${var.worker}-ec2"

# network.tf
cidr_block = var.vpc_cidr
cidr_blocks = [var.vpc_cidr]

# compute.tf
ami           = var.ami
instance_type = var.instance_type
```

## 변수 덮어쓰기

기본값 외 다른 값으로 실행하려면:

```bash
# 실행 시 직접 지정
terraform apply -var="team=myteam" -var="region=ap-northeast-2"

# tfvars 파일 사용
terraform apply -var-file="custom.tfvars"
```

---

[Terraform MOC](../../Terraform_MOC.md)
