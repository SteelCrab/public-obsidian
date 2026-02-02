# Git Pull

#git #pull #원격

---

원격 변경사항을 가져와 병합한다. (fetch + merge)

| 명령어 | 설명 |
|--------|------|
| `git pull` | fetch + merge |
| `git pull origin <브랜치>` | 특정 브랜치 pull |
| `git pull --rebase` | fetch + rebase |
| `git pull --ff-only` | fast-forward만 허용 |
| `git pull --no-commit` | 자동 커밋 없이 |

## Pull 전략 설정

```bash
# 기본 전략을 rebase로
git config --global pull.rebase true

# fast-forward만 허용
git config --global pull.ff only
```

> [!tip] rebase vs merge
> `--rebase`: 히스토리가 깔끔해짐
> 기본 merge: 병합 커밋이 생김

---

## 연결 노트

- [[git-fetch]] - 페치만
- [[git-fetch-vs-pull]] - fetch vs pull 차이
- [[git-merge]] - 병합
- [[git-rebase]] - 리베이스
- [[Git_MOC]]
