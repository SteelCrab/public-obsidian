# Git Merge

#git #merge #병합

---

브랜치를 현재 브랜치에 병합한다.

| 명령어 | 설명 |
|--------|------|
| `git merge <브랜치>` | 브랜치 병합 |
| `git merge --no-ff <브랜치>` | 항상 merge 커밋 생성 |
| `git merge --ff-only <브랜치>` | fast-forward만 허용 |
| `git merge --squash <브랜치>` | 커밋 합쳐서 병합 |
| `git merge --no-commit <브랜치>` | 자동 커밋 없이 |
| `git merge --abort` | 병합 취소 |

## Merge 전략

```bash
# 기본 병합 (3-way merge)
git merge feature

# merge 커밋 항상 생성 (히스토리 명확)
git merge --no-ff feature

# 하나의 커밋으로 합치기
git merge --squash feature
git commit -m "Merge feature"
```

> [!tip] --no-ff 사용 이유
> 히스토리에서 병합 지점이 명확히 보인다.
> 팀 작업 시 권장.
