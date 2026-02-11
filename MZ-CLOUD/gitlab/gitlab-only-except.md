# GitLab Only/Except

#gitlab #cicd #only #except #legacy

---

잡 실행 조건 (레거시, `rules` 권장).

## only

특정 조건에서만 실행.

```yaml
job:
  script: echo "Deploy"
  only:
    - main
    - tags
```

## except

특정 조건에서 제외.

```yaml
job:
  script: echo "Test"
  except:
    - schedules
```

## 조건 유형

| 조건 | 설명 |
|------|------|
| `branches` | 브랜치 |
| `tags` | 태그 |
| `api` | API 트리거 |
| `schedules` | 스케줄 |
| `web` | 웹 UI |
| `merge_requests` | MR |

## refs와 changes

```yaml
job:
  only:
    refs:
      - main
    changes:
      - src/**/*
```

## variables

```yaml
job:
  only:
    variables:
      - $DEPLOY == "true"
```

## rules로 마이그레이션

```yaml
# only/except (레거시)
only:
  - main

# rules (권장)
rules:
  - if: $CI_COMMIT_BRANCH == "main"
```
