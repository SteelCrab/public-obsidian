# Terraform provider.tf 설정

#terraform #provider #aws #버전 #리전

---

`provider.tf`는 사용할 CSP(Cloud Service Provider), 라이브러리 소스, 버전, 리전을 선언하는 파일입니다.

## 파일 구조

```hcl
# CSP, 라이브러리, 버전 선언
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 리전 설정
provider "aws" {
  region = "ap-southeast-1"
}
```

## terraform 블록

| 항목 | 설명 |
|------|------|
| `required_providers` | 사용할 provider 목록 선언 |
| `source` | provider 레지스트리 주소 (`<namespace>/<type>`) |
| `version` | 버전 제약 표현식 |

### 버전 제약 표현식

| 표현식 | 의미 |
|--------|------|
| `~> 5.0` | `5.0` 이상 `6.0` 미만 (패치 버전만 허용) |
| `~> 5.1.2` | `5.1.2` 이상 `5.2.0` 미만 |
| `>= 5.0` | `5.0` 이상 모든 버전 |
| `= 5.0.0` | 정확히 `5.0.0` 고정 |

## provider 블록

| 항목 | 설명 |
|------|------|
| `region` | 리소스를 배포할 AWS 리전 |

### AWS 주요 리전

| 리전 코드 | 위치 |
|-----------|------|
| `ap-southeast-1` | 싱가포르 |

---


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