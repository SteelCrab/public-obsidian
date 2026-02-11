# GitLab Rules

#gitlab #cicd #rules

---

잡 실행 조건을 정의하는 현대적 방식.

## 기본 사용

```yaml
job:
  script: echo "Hello"
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

## 규칙 키워드

| 키워드 | 설명 |
|--------|------|
| `if` | 조건식 |
| `changes` | 파일 변경 감지 |
| `exists` | 파일 존재 확인 |
| `when` | 실행 시점 |

## if 조건

```yaml
rules:
  - if: $CI_COMMIT_BRANCH == "main"
    when: always
  - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    when: manual
  - when: never
```

## changes

```yaml
rules:
  - changes:
      - src/**/*
      - package.json
```

## exists

```yaml
rules:
  - exists:
      - Dockerfile
```

## when 값

| 값 | 설명 |
|----|------|
| `on_success` | 이전 스테이지 성공 시 (기본) |
| `always` | 항상 |
| `never` | 실행 안 함 |
| `manual` | 수동 실행 |
| `delayed` | 지연 실행 |

## 복합 조건

```yaml
rules:
  - if: $CI_COMMIT_BRANCH == "main"
    changes:
      - src/**/*
    when: always
```
