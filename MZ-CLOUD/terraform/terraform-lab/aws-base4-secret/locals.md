# Terraform locals.tf 설정

#terraform #locals #로컬값 #service_name #common_tags #output

---

`locals.tf`는 여러 곳에서 재사용할 로컬 값을 정의하는 파일입니다.
`variables.tf`의 변수를 조합하여 리소스 이름과 공통 태그를 동적으로 생성합니다. → [[variables]] | [[provider]]

## 파일 구조

```hcl
locals {
  service_name = "${var.team}-${var.worker}-ec2"
  common_tags = {
    Project_name = local.service_name
    Managed      = "Terraform"
  }
}

output "service_name" {
  value = local.service_name
}
```

## locals 블록

| 로컬 변수 | 표현식 | 결과값 (기본값 기준) |
|-----------|--------|---------------------|
| `service_name` | `"${var.team}-${var.worker}-ec2"` | `pista-worker-ec2` |
| `common_tags` | 맵 (`map(string)`) | 아래 테이블 참고 |

### service_name 조합 로직

```
var.team   +  "-"  +  var.worker  +  "-ec2"
"pista"         +      "worker"      +  "-ec2"
= "pista-worker-ec2"
```

> `var.team` 또는 `var.worker` 값을 바꾸면 모든 리소스 이름이 자동으로 변경됩니다.

### common_tags 구조

| 태그 키 | 값 | 설명 |
|---------|-----|------|
| `Project_name` | `local.service_name` (`pista-worker-ec2`) | 프로젝트명 (동적 생성) |
| `Managed` | `Terraform` | IaC 관리 도구 식별 |

## output 블록

| 항목 | 설명 |
|------|------|
| `output "service_name"` | `terraform apply` 완료 후 터미널에 출력 |
| `value` | 출력할 값 (`local.service_name`) |

```bash
# terraform apply 완료 후 출력 예시
Outputs:

service_name = "pista-worker-ec2"
```

## locals 참조 방법

| 참조 위치 | 표현식 | 예시 |
|-----------|--------|------|
| 리소스 태그 | `local.service_name` | `tags = { Name = "${local.service_name}-vpc" }` |
| provider 태그 | `local.common_tags` | `tags = local.common_tags` |
| locals 내부 | `local.<이름>` | `Project_name = local.service_name` |

---

[Terraform MOC](../../Terraform_MOC.md)
