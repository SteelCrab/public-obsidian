# GitLab 환경

#gitlab #cicd #environments #deploy

---

배포 대상 환경 정의 및 추적.

## 기본 사용

```yaml
deploy_staging:
  stage: deploy
  script: ./deploy.sh staging
  environment:
    name: staging
    url: https://staging.example.com
```

## 환경 옵션

| 옵션 | 설명 |
|------|------|
| `name` | 환경 이름 |
| `url` | 환경 URL |
| `on_stop` | 중지 잡 |
| `auto_stop_in` | 자동 중지 |
| `action` | start/stop |

## 동적 환경

```yaml
deploy_review:
  script: ./deploy.sh $CI_COMMIT_REF_SLUG
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    url: https://$CI_COMMIT_REF_SLUG.example.com
```

## 환경 중지

```yaml
deploy_review:
  script: ./deploy.sh
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    on_stop: stop_review

stop_review:
  script: ./stop.sh
  when: manual
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    action: stop
```

## 자동 중지

```yaml
environment:
  name: review/$CI_COMMIT_REF_SLUG
  auto_stop_in: 1 week
```

## 프로덕션 환경

```yaml
deploy_prod:
  stage: deploy
  script: ./deploy.sh production
  environment:
    name: production
    url: https://example.com
  when: manual
  only:
    - main
```
