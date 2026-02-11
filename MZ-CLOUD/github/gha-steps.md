# GitHub Actions 스텝 구성

#github #actions #steps

---

잡 내에서 순차 실행되는 개별 작업.

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v4

  - name: Setup Node
    uses: actions/setup-node@v4
    with:
      node-version: '20'

  - name: Install
    run: npm ci

  - name: Build
    run: npm run build
    env:
      NODE_ENV: production

  - name: Multi-line script
    run: |
      echo "Line 1"
      echo "Line 2"
```

| 키 | 설명 |
|-----|------|
| `name` | 스텝 이름 |
| `uses` | 액션 사용 |
| `run` | 쉘 명령 실행 |
| `with` | 액션 입력값 |
| `env` | 환경변수 |
| `if` | 실행 조건 |
| `id` | 스텝 ID (출력 참조용) |
| `continue-on-error` | 실패해도 계속 |
| `timeout-minutes` | 타임아웃 |
| `working-directory` | 작업 디렉토리 |
| `shell` | 쉘 지정 (bash, pwsh 등) |
