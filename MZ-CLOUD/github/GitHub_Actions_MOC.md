# GitHub Actions MOC

#github #actions #yaml #MOC #cicd

---

GitHub Actions 워크플로우 YAML 구성을 연결하는 허브 노트.

---

## 기본 구조

- [[gha-workflow]] - 워크플로우 기본
- [[gha-triggers]] - 트리거 (on)
- [[gha-paths]] - 경로 필터
- [[gha-jobs]] - 잡 구성
- [[gha-steps]] - 스텝 구성
- [[gha-checkout]] - 코드 체크아웃

---

## 실행 환경

- [[gha-runners]] - 러너 설정
- [[gha-env]] - 환경변수
- [[gha-secrets]] - 시크릿
- [[gha-matrix]] - 매트릭스 빌드

---

## 흐름 제어

- [[gha-conditions]] - 조건 (if)
- [[gha-needs]] - 잡 의존성
- [[gha-concurrency]] - 동시성 제어

---

## 데이터 관리

- [[gha-artifacts]] - 아티팩트
- [[gha-cache]] - 캐싱
- [[gha-outputs]] - 출력값

---

## Docker

- [[gha-docker-login]] - 레지스트리 로그인
- [[gha-docker-buildx]] - Buildx 설정
- [[gha-docker-build]] - 빌드 및 푸시

---

## AWS

- [[gha-aws-configure]] - AWS 인증 설정
- [[gha-ecr-login]] - ECR 로그인
- [[gha-s3-sync]] - S3 동기화

---

## 배포

- [[gha-deploy-ssh]] - SSH 배포 (EC2)
- [[gha-deploy-ssm]] - SSM 배포 (EC2)

---

## Setup Actions

- [[gha-setup-python]] - Python 설정

---

## 예시

- [[gha-example-fastapi-dockerhub]] - FastAPI + Docker Hub + EC2 배포
- [[gha-example-nginx-dockerhub]] - Nginx + Docker Hub + EC2 배포
- [[gha-example-fastapi-ecr-ssm]] - FastAPI + ECR + SSM 배포
- [[gha-example-nginx-ecr-ssm]] - Nginx + ECR + SSM 배포  
* [[gha-gha-example-s3-ecr-ssm]] - S3 + SSM 배포
---

## 빠른 참조

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: npm test
```

---

## 외부 링크

- [GitHub Actions 문서](https://docs.github.com/en/actions)
- [워크플로우 문법](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)

---

*Zettelkasten 스타일로 구성됨*
