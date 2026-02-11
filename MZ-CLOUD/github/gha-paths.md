# GitHub Actions 경로 필터

#github #actions #paths #trigger #filter

---

특정 파일/디렉토리 변경 시에만 워크플로우 실행.

## 기본 사용

```yaml
on:
  push:
    paths:
      - "src/**"
      - "package.json"
```

## 제외 패턴

```yaml
on:
  push:
    paths-ignore:
      - "docs/**"
      - "*.md"
```

## 여러 브랜치 + 경로

```yaml
on:
  push:
    branches: ["main", "develop"]
    paths:
      - "api/**"
      - "tests/**"
```

## 모노레포 예시

```yaml
on:
  push:
    paths:
      - "frontend/**"
  pull_request:
    paths:
      - "frontend/**"
```

## 패턴 규칙

| 패턴 | 설명 |
|------|------|
| `**` | 모든 디렉토리 매칭 |
| `*` | 파일명 매칭 |
| `*.js` | 확장자 매칭 |
| `src/**/*.ts` | 중첩 경로 매칭 |
| `!*.md` | 제외 (paths-ignore 대신 사용) |

## 주의사항

- `paths`와 `paths-ignore`를 동시에 사용할 수 없음
- 대소문자 구분 안 함 (case-insensitive)
- 변경된 파일 중 하나라도 매칭되면 실행
- PR에서는 베이스 브랜치와 비교

## 실전 예시

```yaml
on:
  push:
    branches: ["main"]
    paths:
      - "app/**"
      - "Dockerfile"
      - ".github/workflows/**"
    paths-ignore:
      - "**.md"
```
