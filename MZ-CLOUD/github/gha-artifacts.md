# GitHub Actions 아티팩트

#github #actions #artifacts

---

빌드 결과물 저장 및 공유.

## 업로드

```yaml
steps:
  - run: npm run build

  - uses: actions/upload-artifact@v4
    with:
      name: build-output
      path: dist/
      retention-days: 5
```

## 다운로드

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/
      - run: ./deploy.sh
```

## 옵션

| 옵션 | 설명 |
|------|------|
| `name` | 아티팩트 이름 |
| `path` | 파일/디렉토리 경로 |
| `retention-days` | 보관 기간 (기본 90일) |
| `if-no-files-found` | 파일 없을 때 (warn, error, ignore) |
| `compression-level` | 압축 레벨 (0-9) |
