# Terraform provider.tf 설정 (aws-base1-2)

#terraform #provider #aws #버전 #리전 #default_tags #locals

---

`provider.tf`는 사용할 CSP, 라이브러리 소스, 버전, 리전을 선언하는 파일입니다.
`default_tags`는 `locals.tf`의 `common_tags`를 참조합니다. → [[locals]]

## 파일 구조

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
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

| 항목 | 값 | 설명 |
|------|-----|------|
| `region` | `var.region` | 변수로 리전을 주입 (기본값: `ap-southeast-1`) |
| `default_tags` | `local.common_tags` | `locals.tf`에서 정의한 공통 태그 참조 |

### default_tags + locals 연동

`aws-basic1`은 `default_tags`에 태그를 직접 하드코딩했지만, `aws-base1-2`은 `locals.common_tags`를 참조합니다.

| 방식 | 코드 | 특징 |
|------|------|------|
| 하드코딩 (aws-basic1) | `tags = { Username = "pista", ... }` | 간단하지만 재사용 어려움 |
| locals 참조 (aws-base1-2) | `tags = local.common_tags` | 한 곳에서 관리, 재사용 가능 |

> `default_tags`에 설정하면 `provider "aws"` 범위 내 **모든 리소스에 자동으로 태그가 추가**됩니다.
> 리소스 단위 `tags`와 `default_tags`가 동시에 있으면 **병합**됩니다. 키 충돌 시 리소스 단위 태그가 우선합니다.

## 실행 방법

```bash
terraform init
terraform plan
terraform apply
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
