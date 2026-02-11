# GitLab 파이프라인

#gitlab #cicd #pipeline

---

`.gitlab-ci.yml` 파일로 정의되는 CI/CD 파이프라인.

## 기본 구조

```yaml
stages:
  - build
  - test
  - deploy

build_job:
  stage: build
  script:
    - echo "Building..."

test_job:
  stage: test
  script:
    - echo "Testing..."

deploy_job:
  stage: deploy
  script:
    - echo "Deploying..."
```

## 파이프라인 트리거

| 트리거 | 설명 |
|--------|------|
| Push | 커밋 푸시 시 |
| Merge Request | MR 생성/업데이트 시 |
| Schedule | 스케줄 실행 |
| API | API 호출 |
| Web | UI에서 수동 실행 |

## 파이프라인 상태

| 상태 | 설명 |
|------|------|
| `pending` | 대기 중 |
| `running` | 실행 중 |
| `success` | 성공 |
| `failed` | 실패 |
| `canceled` | 취소됨 |
| `skipped` | 건너뜀 |
