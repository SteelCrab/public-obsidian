# GitHub Actions 매트릭스 빌드

#github #actions #matrix

---

여러 조합으로 병렬 실행.

## 기본 매트릭스

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node: [18, 20, 22]
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
```

## 다중 매트릭스

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    node: [18, 20]
# 4개 조합 실행: ubuntu+18, ubuntu+20, windows+18, windows+20
```

## include/exclude

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    node: [18, 20]
    exclude:
      - os: windows-latest
        node: 18
    include:
      - os: ubuntu-latest
        node: 22
        experimental: true
```

## 실패 처리

```yaml
strategy:
  fail-fast: false  # 하나 실패해도 나머지 계속
  max-parallel: 2   # 동시 실행 수 제한
  matrix:
    node: [18, 20, 22]
```
