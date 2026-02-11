# GitLab 스크립트

#gitlab #cicd #script

---

잡에서 실행되는 셸 명령어.

## 스크립트 종류

| 키워드 | 설명 |
|--------|------|
| `before_script` | script 전에 실행 |
| `script` | 메인 명령어 (필수) |
| `after_script` | script 후 실행 (실패해도 실행) |

## 기본 사용

```yaml
job:
  before_script:
    - echo "Setup"
  script:
    - echo "Main"
    - npm test
  after_script:
    - echo "Cleanup"
```

## 여러 줄 명령어

```yaml
job:
  script:
    - |
      echo "Line 1"
      echo "Line 2"
      echo "Line 3"
```

## 전역 before_script

```yaml
default:
  before_script:
    - npm install

job1:
  script: npm run build

job2:
  script: npm test
```

## after_script 특징

- 별도의 셸에서 실행
- 작업 디렉토리가 리셋됨
- 타임아웃: 5분
