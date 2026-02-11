# GitHub Actions 캐싱

#github #actions #cache

---

의존성 캐싱으로 빌드 속도 향상.

## 기본 캐시

```yaml
steps:
  - uses: actions/cache@v4
    with:
      path: ~/.npm
      key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
      restore-keys: |
        ${{ runner.os }}-npm-
```

## Setup 액션 내장 캐시

```yaml
# Node.js
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'

# Python
- uses: actions/setup-python@v5
  with:
    python-version: '3.12'
    cache: 'pip'

# Go
- uses: actions/setup-go@v5
  with:
    go-version: '1.22'
    cache: true
```

## 언어별 캐시 경로

| 언어 | 경로 | 키 파일 |
|------|------|---------|
| npm | `~/.npm` | `package-lock.json` |
| yarn | `~/.cache/yarn` | `yarn.lock` |
| pnpm | `~/.pnpm-store` | `pnpm-lock.yaml` |
| pip | `~/.cache/pip` | `requirements.txt` |
| gradle | `~/.gradle/caches` | `*.gradle*` |
| maven | `~/.m2/repository` | `pom.xml` |
