# GitLab 캐시

#gitlab #cicd #cache

---

파이프라인 간에 파일을 캐싱하여 속도 향상.

## 기본 사용

```yaml
job:
  cache:
    paths:
      - node_modules/
  script:
    - npm install
    - npm test
```

## 캐시 키

```yaml
cache:
  key: $CI_COMMIT_REF_SLUG
  paths:
    - node_modules/
```

## 파일 기반 키

```yaml
cache:
  key:
    files:
      - package-lock.json
  paths:
    - node_modules/
```

## 캐시 정책

| 정책 | 설명 |
|------|------|
| `pull-push` | 다운로드 + 업로드 (기본) |
| `pull` | 다운로드만 |
| `push` | 업로드만 |

```yaml
build:
  cache:
    policy: pull-push
    paths:
      - node_modules/

test:
  cache:
    policy: pull
    paths:
      - node_modules/
```

## 전역 캐시

```yaml
default:
  cache:
    paths:
      - node_modules/

build:
  script: npm run build

test:
  script: npm test
```

## 캐시 vs 아티팩트

| 항목 | 캐시 | 아티팩트 |
|------|------|----------|
| 용도 | 속도 최적화 | 잡 간 데이터 전달 |
| 보장 | 없음 | 있음 |
| 범위 | 파이프라인 간 | 파이프라인 내 |
