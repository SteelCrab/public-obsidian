# GitHub Actions 환경변수

#github #actions #env

---

환경변수 설정 및 사용.

## 레벨별 설정

```yaml
env:
  GLOBAL_VAR: 'global'

jobs:
  build:
    env:
      JOB_VAR: 'job'
    steps:
      - env:
          STEP_VAR: 'step'
        run: echo "$GLOBAL_VAR $JOB_VAR $STEP_VAR"
```

## 기본 제공 변수

| 변수 | 설명 |
|------|------|
| `GITHUB_SHA` | 커밋 SHA |
| `GITHUB_REF` | 브랜치/태그 ref |
| `GITHUB_REPOSITORY` | 저장소 이름 |
| `GITHUB_ACTOR` | 실행자 |
| `GITHUB_WORKFLOW` | 워크플로우 이름 |
| `GITHUB_RUN_ID` | 실행 ID |
| `GITHUB_RUN_NUMBER` | 실행 번호 |
| `RUNNER_OS` | 러너 OS |

## 컨텍스트 사용

```yaml
steps:
  - run: echo "${{ github.sha }}"
  - run: echo "${{ runner.os }}"
  - run: echo "${{ env.MY_VAR }}"
```
