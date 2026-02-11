# GitHub Actions 잡 의존성

#github #actions #needs

---

잡 간 실행 순서 및 데이터 전달.

## 기본 의존성

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm build

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  deploy:
    needs: [build, test]
    runs-on: ubuntu-latest
    steps:
      - run: ./deploy.sh
```

## 의존 잡 결과 확인

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: exit 1

  notify:
    needs: build
    if: always()
    runs-on: ubuntu-latest
    steps:
      - run: echo "Build result: ${{ needs.build.result }}"
      # result: success, failure, cancelled, skipped
```

## 잡 간 데이터 전달

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.get-version.outputs.version }}
    steps:
      - id: get-version
        run: echo "version=1.0.0" >> $GITHUB_OUTPUT

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying ${{ needs.build.outputs.version }}"
```
