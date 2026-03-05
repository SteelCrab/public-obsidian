# Terraform main.tf 설정

#terraform #main #aws #ec2 #instance

---

`main.tf`는 실제 배포할 리소스를 정의하는 파일입니다.
`provider.tf`에서 선언한 CSP(AWS)를 기반으로 리소스를 생성합니다. → [[provider]]

## 파일 구조

```hcl
resource "aws_instance" "name" {
  ami           = "ami-054240677cb44ffac"
  instance_type = "t3.micro"

  tags = {
    Name = "pista-test-ec2"
  }
}
```

## resource 블록

| 항목 | 설명 |
|------|------|
| `resource "aws_instance"` | 리소스 타입 (AWS EC2 인스턴스) |
| `"name"` | 로컬 이름 (Terraform 내부 참조용) |
| `ami` | 사용할 AMI ID (리전별로 다름) |
| `instance_type` | EC2 인스턴스 타입 |
| `tags` | AWS 리소스에 붙이는 메타데이터 |

### 주요 instance_type

| 타입 | vCPU | 메모리 | 용도 |
|------|------|--------|------|
| `t3.micro` | 2 | 1 GB | 테스트 / 프리티어 |
| `t3.small` | 2 | 2 GB | 경량 서버 |
| `t3.medium` | 2 | 4 GB | 일반 서버 |

### AMI (ap-southeast-1 기준)

| OS | AMI ID |
|----|--------|
| Ubuntu Server 24.04 LTS  | `ami-054240677cb44ffac` |

## 실행 방법

```bash
# 1. 초기화 (provider 플러그인 다운로드)
terraform init

# 2. 실행 계획 확인 (변경 사항 미리 보기)
terraform plan

# 3. 리소스 생성
terraform apply

# 4. 리소스 삭제
terraform destroy
```

| 명령어 | 설명 |
|--------|------|
| `terraform init` | provider 플러그인 설치, `.terraform/` 생성 |
| `terraform plan` | 생성/수정/삭제될 리소스 미리 확인 |
| `terraform apply` | 실제 리소스 배포 (`yes` 입력 필요) |
| `terraform destroy` | 모든 리소스 삭제 (`yes` 입력 필요) |

---

[Terraform MOC](../../Terraform_MOC.md)
