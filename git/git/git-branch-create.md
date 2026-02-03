# Git 브랜치 생성

#git #branch #생성

---

새로운 브랜치를 만든다.

| 명령어 | 설명 |
|--------|------|
| `git branch <브랜치명>` | 브랜치 생성 (전환 X) |
| `git branch <브랜치명> <커밋>` | 특정 커밋에서 생성 |
| `git checkout -b <브랜치명>` | 생성 + 전환 |
| `git switch -c <브랜치명>` | 생성 + 전환 (신규) |
| `git checkout -b <브랜치> <원격>/<브랜치>` | 원격 브랜치 기반 |

## 일반적인 사용

```bash
# 새 기능 브랜치 생성 후 바로 이동
git switch -c feature/login

# 특정 커밋에서 브랜치 생성
git branch hotfix/bug abc1234
```

---

## 연결 노트

- [[git-branch-switch]] - 브랜치 전환
- [[git-branch-delete]] - 브랜치 삭제
- [[git-branch-list]] - 브랜치 조회
- [[git-checkout-vs-switch]] - checkout vs switch
- [[Git_MOC]]
