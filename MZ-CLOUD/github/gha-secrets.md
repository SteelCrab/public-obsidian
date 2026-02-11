# GitHub Actions 시크릿

#github #actions #secrets

---

민감한 정보 관리.

## 사용법

```yaml
steps:
  - name: Deploy
    env:
      API_KEY: ${{ secrets.API_KEY }}
    run: ./deploy.sh

  - name: Login
    uses: docker/login-action@v3
    with:
      username: ${{ secrets.DOCKER_USERNAME }}
      password: ${{ secrets.DOCKER_PASSWORD }}
```

## 기본 제공 시크릿

| 시크릿 | 설명 |
|--------|------|
| `GITHUB_TOKEN` | 자동 생성되는 토큰 |

## GITHUB_TOKEN 권한

```yaml
permissions:
  contents: read
  packages: write
  pull-requests: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "${{ secrets.GITHUB_TOKEN }}"
```

## 환경별 시크릿

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - run: echo "${{ secrets.PROD_API_KEY }}"
```
