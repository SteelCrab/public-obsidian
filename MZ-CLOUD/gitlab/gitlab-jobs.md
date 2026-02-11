# GitLab 잡

#gitlab #cicd #jobs

---

파이프라인에서 실행되는 개별 작업 단위.

## 기본 구조

```yaml
job_name:
  stage: build
  script:
    - echo "Hello"
```

## 주요 키워드

| 키워드 | 설명 |
|--------|------|
| `stage` | 소속 스테이지 |
| `script` | 실행 명령어 |
| `image` | Docker 이미지 |
| `variables` | 환경변수 |
| `artifacts` | 아티팩트 |
| `cache` | 캐시 |
| `rules` | 실행 조건 |
| `needs` | 의존 잡 |
| `tags` | 러너 태그 |

## 숨김 잡

`.`으로 시작하면 실행되지 않음 (템플릿용).

```yaml
.template:
  image: node:20
  before_script:
    - npm install

build:
  extends: .template
  script:
    - npm run build
```

## extends

템플릿 상속.

```yaml
build:
  extends: .template
  script:
    - npm run build
```
