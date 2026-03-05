# Terraform VSCode 확장 설치 및 설정

#terraform #vscode #설정 #formatonsave

---

HashiCorp 공식 Terraform VSCode 확장을 설치하고 저장 시 자동 포매팅(`editor.formatOnSave`)을 설정합니다.

## 1. 확장 설치

VSCode Extensions 마켓플레이스에서 **HashiCorp Terraform** 검색 후 설치합니다.

```
확장 ID: hashicorp.terraform
```

또는 VSCode 터미널에서:

```bash
code --install-extension hashicorp.terraform
```

## 2. `editor.formatOnSave` 설정

`settings.json`에 다음을 추가합니다.

```json
{
  "[terraform]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "hashicorp.terraform"
  },
  "[terraform-vars]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "hashicorp.terraform"
  }
}
```

> 저장 시 `terraform fmt`와 동일한 포매팅이 자동 적용됩니다.

## 3. 주요 기능

| 기능 | 설명 |
|------|------|
| 자동 포매팅 | 저장 시 `terraform fmt` 자동 실행 |
| 구문 강조 | `.tf`, `.tfvars` 파일 하이라이팅 |
| 자동 완성 | 리소스, 변수, 함수 IntelliSense |
| 유효성 검사 | HCL 문법 오류 실시간 감지 |
| Go to Definition | 리소스/모듈 정의로 이동 |

---

[Terraform MOC](./Terraform_MOC.md)
