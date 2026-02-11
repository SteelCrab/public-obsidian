# GitLab 스테이지

#gitlab #cicd #stages

---

파이프라인의 실행 단계 정의.

## 기본 사용

```yaml
stages:
  - build
  - test
  - deploy
```

## 기본 스테이지 (미정의 시)

```yaml
stages:
  - .pre
  - build
  - test
  - deploy
  - .post
```

## 특수 스테이지

| 스테이지 | 설명 |
|----------|------|
| `.pre` | 항상 첫 번째로 실행 |
| `.post` | 항상 마지막으로 실행 |

## 병렬 실행

같은 스테이지의 잡들은 병렬로 실행됨.

```yaml
stages:
  - test

unit_test:
  stage: test
  script: npm run test:unit

e2e_test:
  stage: test
  script: npm run test:e2e
```
