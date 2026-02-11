# GitLab When

#gitlab #cicd #when

---

잡 실행 시점 제어.

## when 값

| 값 | 설명 |
|----|------|
| `on_success` | 이전 스테이지 성공 시 (기본) |
| `on_failure` | 이전 스테이지 실패 시 |
| `always` | 항상 실행 |
| `never` | 실행 안 함 |
| `manual` | 수동 실행 |
| `delayed` | 지연 실행 |

## 기본 사용

```yaml
job:
  script: echo "Hello"
  when: manual
```

## 실패 시 알림

```yaml
notify:
  stage: .post
  when: on_failure
  script: ./send-notification.sh
```

## 클린업

```yaml
cleanup:
  stage: .post
  when: always
  script: ./cleanup.sh
```

## 수동 실행

```yaml
deploy_prod:
  stage: deploy
  when: manual
  script: ./deploy.sh production
```

## 지연 실행

```yaml
delayed_job:
  when: delayed
  start_in: 30 minutes
  script: echo "Delayed"
```

## rules에서 when

```yaml
rules:
  - if: $CI_COMMIT_BRANCH == "main"
    when: always
  - when: manual
```
