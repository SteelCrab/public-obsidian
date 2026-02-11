# GitHub Actions 출력값

#github #actions #outputs

---

스텝/잡 간 데이터 전달.

## 스텝 출력

```yaml
steps:
  - id: get-version
    run: echo "version=1.2.3" >> $GITHUB_OUTPUT

  - run: echo "Version is ${{ steps.get-version.outputs.version }}"
```

## 멀티라인 출력

```yaml
steps:
  - id: get-changelog
    run: |
      {
        echo 'changelog<<EOF'
        cat CHANGELOG.md
        echo EOF
      } >> $GITHUB_OUTPUT
```

## 잡 출력

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.vars.outputs.version }}
      sha_short: ${{ steps.vars.outputs.sha_short }}
    steps:
      - id: vars
        run: |
          echo "version=$(cat VERSION)" >> $GITHUB_OUTPUT
          echo "sha_short=$(git rev-parse --short HEAD)" >> $GITHUB_OUTPUT

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo "Version: ${{ needs.build.outputs.version }}"
          echo "SHA: ${{ needs.build.outputs.sha_short }}"
```

## 환경 파일

| 파일 | 용도 |
|------|------|
| `$GITHUB_OUTPUT` | 스텝 출력 |
| `$GITHUB_ENV` | 환경변수 설정 |
| `$GITHUB_PATH` | PATH 추가 |
| `$GITHUB_STEP_SUMMARY` | 잡 요약 |
