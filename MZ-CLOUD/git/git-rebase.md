# Git Rebase

#git #rebase #리베이스

---

커밋의 기준점을 다른 브랜치로 옮긴다.

| 명령어 | 설명 |
|--------|------|
| `git rebase <브랜치>` | 리베이스 |
| `git rebase main` | main 기준으로 리베이스 |
| `git rebase --onto <새기준> <이전기준> <브랜치>` | 기준점 변경 |
| `git rebase --continue` | 충돌 해결 후 계속 |
| `git rebase --abort` | 리베이스 취소 |
| `git rebase --skip` | 현재 커밋 건너뛰기 |

## 기본 사용법

```bash
# feature 브랜치에서
git checkout feature
git rebase main

# main의 최신 커밋 위로 feature 커밋들이 이동
```

> [!warning] Rebase 주의
> - 이미 push한 커밋은 rebase 금지
> - 공유 브랜치에서는 merge 사용
> - force push가 필요할 수 있음
