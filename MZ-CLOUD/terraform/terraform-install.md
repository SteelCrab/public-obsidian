# Terraform 설치

#terraform #설치 #brew

---

Terraform 설치 방법 (macOS / Windows)

## macOS (Homebrew)

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

설치 확인:
```bash
terraform -version
```

업데이트:
```bash
brew update
brew upgrade hashicorp/tap/terraform
```

## Windows (수동 설치)

1. [Terraform 다운로드 페이지](https://developer.hashicorp.com/terraform/downloads)에서 Windows AMD64 zip 파일 다운로드
2. zip 파일 압축 해제 → `terraform.exe` 추출
3. 원하는 경로에 배치 (예: `C:\terraform\`)
4. 시스템 환경 변수 Path에 해당 경로 추가:
   - `시스템 속성` → `환경 변수` → `Path` → `편집` → `C:\terraform\` 추가
5. 새 cmd/PowerShell에서 확인:
```powershell
terraform -version
```

## 설치 후 초기 설정 (GCP)

```bash
# GCP 인증
gcloud auth application-default login

# 프로젝트 설정
gcloud config set project <PROJECT_ID>
```

[Terraform MOC](./Terraform_MOC.md)
