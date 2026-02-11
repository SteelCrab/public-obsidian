# GitHub Actions 워크플로우 기본

#github #actions #workflow

---

워크플로우 파일 기본 구조. `.github/workflows/` 디렉토리에 위치.

```yaml
name: 워크플로우 이름

on: [push]

jobs:
  job-name:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Hello"
```

| 키 | 설명 |
|-----|------|
| `name` | 워크플로우 이름 (선택) |
| `on` | 트리거 이벤트 |
| `jobs` | 실행할 잡 목록 |
| `env` | 전역 환경변수 |
| `permissions` | GITHUB_TOKEN 권한 |
| `defaults` | 기본 설정 |
