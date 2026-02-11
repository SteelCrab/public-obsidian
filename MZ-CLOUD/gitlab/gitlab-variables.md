# GitLab 변수

#gitlab #cicd #variables

---

CI/CD 파이프라인에서 사용하는 환경변수.

## 변수 정의

```yaml
variables:
  APP_NAME: "myapp"
  NODE_ENV: "production"

job:
  script:
    - echo $APP_NAME
```

## 변수 레벨

| 레벨 | 설명 |
|------|------|
| 인스턴스 | 전체 GitLab |
| 그룹 | 그룹 내 프로젝트 |
| 프로젝트 | 단일 프로젝트 |
| 파이프라인 | `.gitlab-ci.yml` |
| 잡 | 개별 잡 |

## 사전 정의 변수

| 변수 | 설명 |
|------|------|
| `CI_COMMIT_SHA` | 커밋 SHA |
| `CI_COMMIT_REF_NAME` | 브랜치/태그명 |
| `CI_PIPELINE_ID` | 파이프라인 ID |
| `CI_JOB_ID` | 잡 ID |
| `CI_PROJECT_NAME` | 프로젝트명 |
| `CI_REGISTRY_IMAGE` | 레지스트리 이미지 경로 |

## 보호된 변수

Settings > CI/CD > Variables에서 설정.

| 옵션 | 설명 |
|------|------|
| Protected | 보호된 브랜치에서만 사용 |
| Masked | 로그에서 마스킹 |

## 잡별 변수

```yaml
job:
  variables:
    LOCAL_VAR: "value"
  script:
    - echo $LOCAL_VAR
```
