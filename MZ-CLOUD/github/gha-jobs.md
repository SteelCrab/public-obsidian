# GitHub Actions 잡 구성

#github #actions #jobs

---

병렬 또는 순차 실행되는 작업 단위.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm build

  test:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - run: npm test

  deploy:
    runs-on: ubuntu-latest
    needs: [build, test]
    if: github.ref == 'refs/heads/main'
    steps:
      - run: ./deploy.sh
```

| 키 | 설명 |
|-----|------|
| `runs-on` | 러너 지정 |
| `needs` | 의존 잡 |
| `if` | 실행 조건 |
| `steps` | 실행 스텝 |
| `env` | 잡 환경변수 |
| `timeout-minutes` | 타임아웃 |
| `continue-on-error` | 실패해도 계속 |
| `strategy` | 매트릭스 전략 |
| `container` | 컨테이너에서 실행 |
| `services` | 서비스 컨테이너 |
