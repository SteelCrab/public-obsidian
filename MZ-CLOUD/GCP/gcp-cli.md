# gcloud CLI 설치

#gcp #gcloud #CLI #설치

---

GCP의 명령줄 도구인 gcloud CLI 설치 및 초기 설정 방법을 정리한다.

## macOS

```bash
# Homebrew로 설치
brew install --cask google-cloud-sdk

# 또는 공식 스크립트로 설치
curl https://sdk.cloud.google.com | bash

# 셸 재시작
exec -l $SHELL

# 초기화
gcloud init
```

## Linux (Debian/Ubuntu)

```bash
# 패키지 소스 추가
sudo apt-get install -y apt-transport-https ca-certificates gnupg curl

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
    https://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

# 설치
sudo apt-get update && sudo apt-get install -y google-cloud-cli

# 초기화
gcloud init
```

## 설치 확인 및 초기 설정

```bash
# 버전 확인
gcloud version

# 인증 (브라우저 로그인)
gcloud auth login

# 프로젝트 설정
gcloud config set project <PROJECT_ID>

# 기본 리전/존 설정
gcloud config set compute/region asia-northeast3
gcloud config set compute/zone asia-northeast3-a

# 설정 확인
gcloud config list
```
