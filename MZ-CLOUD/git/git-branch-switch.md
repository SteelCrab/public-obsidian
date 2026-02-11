# Git 브랜치 전환

#git #branch #switch #checkout

---

다른 브랜치로 이동한다.

| 명령어 | 설명 |
|--------|------|
| `git checkout <브랜치명>` | 브랜치 전환 |
| `git switch <브랜치명>` | 브랜치 전환 (신규) |
| `git checkout -` | 이전 브랜치로 |
| `git switch -` | 이전 브랜치로 (신규) |

> [!warning] 변경사항이 있을 때
> 커밋하지 않은 변경사항이 있으면 전환이 막힐 수 있다.
> [[git-stash]]로 임시 저장 후 전환하자.
