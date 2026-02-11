# GitHub Actions 체크아웃

#github #actions #checkout #repository

---

리포지토리 코드를 러너로 가져오기.

## actions/checkout

```yaml
- name: Checkout code
  uses: actions/checkout@v4
```

## 특정 브랜치

```yaml
- uses: actions/checkout@v4
  with:
    ref: develop
```

## 전체 히스토리

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0  # 기본값 1 (shallow clone)
```

## 서브모듈 포함

```yaml
- uses: actions/checkout@v4
  with:
    submodules: true
```

## 여러 리포지토리

```yaml
- uses: actions/checkout@v4
  with:
    repository: owner/repo
    token: ${{ secrets.GH_PAT }}
    path: external-repo
```

## 옵션

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `ref` | 브랜치, 태그, 커밋 SHA | 트리거된 ref |
| `fetch-depth` | 가져올 커밋 개수 | 1 |
| `submodules` | 서브모듈 체크아웃 | false |
| `token` | 인증 토큰 | ${{ github.token }} |
| `path` | 체크아웃 경로 | ${{ github.workspace }} |
| `clean` | 체크아웃 전 정리 | true |

## 주의사항

- 대부분의 워크플로우에서 첫 단계로 필요
- `fetch-depth: 0`은 전체 히스토리 필요 시 (예: git log, blame)
- Private 리포지토리는 PAT(Personal Access Token) 필요
