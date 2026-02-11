# GitLab 아티팩트

#gitlab #cicd #artifacts

---

잡 간에 파일을 전달하고 보관.

## 기본 사용

```yaml
build:
  script: npm run build
  artifacts:
    paths:
      - dist/
```

## 주요 옵션

| 옵션 | 설명 |
|------|------|
| `paths` | 저장할 경로 |
| `exclude` | 제외할 경로 |
| `expire_in` | 보관 기간 |
| `name` | 아티팩트 이름 |
| `when` | 저장 시점 |
| `reports` | 리포트 유형 |

## 보관 기간

```yaml
artifacts:
  paths:
    - dist/
  expire_in: 1 week
```

| 값 | 예시 |
|----|------|
| 분 | `30 minutes` |
| 시간 | `2 hours` |
| 일 | `7 days` |
| 주 | `1 week` |
| 월 | `1 month` |
| 영구 | `never` |

## 실패 시에도 저장

```yaml
artifacts:
  when: always
  paths:
    - logs/
```

## 테스트 리포트

```yaml
test:
  script: pytest --junitxml=report.xml
  artifacts:
    reports:
      junit: report.xml
```

## 코드 커버리지

```yaml
test:
  script: pytest --cov
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
```
