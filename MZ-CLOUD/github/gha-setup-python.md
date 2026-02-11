# GitHub Actions Python 설정

#github #actions #python #setup

---

Python 환경 설정.

## 기본 사용

```yaml
steps:
  - uses: actions/checkout@v4

  - uses: actions/setup-python@v5
    with:
      python-version: '3.12'

  - run: python --version
```

## 버전 지정

```yaml
# 정확한 버전
python-version: '3.12.0'

# 마이너 버전
python-version: '3.12'

# 최신 안정 버전
python-version: '3.x'

# 범위 지정
python-version: '>=3.10 <3.13'

# 여러 버전 (매트릭스)
strategy:
  matrix:
    python-version: ['3.10', '3.11', '3.12']
steps:
  - uses: actions/setup-python@v5
    with:
      python-version: ${{ matrix.python-version }}
```

## 캐싱

```yaml
- uses: actions/setup-python@v5
  with:
    python-version: '3.12'
    cache: 'pip'

- run: pip install -r requirements.txt
```

| cache 옵션 | 설명 |
|------------|------|
| `pip` | pip 캐시 |
| `pipenv` | pipenv 캐시 |
| `poetry` | poetry 캐시 |

## 캐시 의존성 파일 지정

```yaml
- uses: actions/setup-python@v5
  with:
    python-version: '3.12'
    cache: 'pip'
    cache-dependency-path: |
      requirements.txt
      requirements-dev.txt
```

## 전체 예시

```yaml
name: Python CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'

      - run: |
          pip install -r requirements.txt
          pytest
```

## 옵션

| 옵션 | 설명 |
|------|------|
| `python-version` | Python 버전 |
| `cache` | 캐시 타입 (pip, pipenv, poetry) |
| `cache-dependency-path` | 캐시 키 파일 |
| `architecture` | x64 또는 x86 |
| `check-latest` | 최신 버전 확인 |
| `token` | GitHub 토큰 |
