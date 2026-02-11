# Semantic Versioning

#git #tag #semver #버전

---

버전 번호 부여 규칙. `MAJOR.MINOR.PATCH` 형식.

## 버전 의미

| 버전 | 변경 시점 |
|------|----------|
| MAJOR (1.x.x) | Breaking changes (하위 호환 X) |
| MINOR (x.1.x) | 기능 추가 (하위 호환 O) |
| PATCH (x.x.1) | 버그 수정 |

## 예시

```
v1.0.0  # 초기 릴리스
v1.0.1  # 버그 수정
v1.1.0  # 새 기능 추가
v2.0.0  # API 변경 (breaking)
```

## 사전 릴리스

```bash
git tag -a v2.0.0-alpha.1 -m "Alpha"
git tag -a v2.0.0-beta.1 -m "Beta"
git tag -a v2.0.0-rc.1 -m "Release candidate"
git tag -a v2.0.0 -m "Stable"
```

## Git 태그 릴리스 워크플로우

```bash
# 1. 버전 태그 생성
git tag -a v1.0.0 -m "Release v1.0.0

Features:
- 로그인 기능
- 회원가입"

# 2. 태그 푸시
git push origin v1.0.0
```
