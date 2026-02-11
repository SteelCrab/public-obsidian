# Git Revert

#git #revert #되돌리기

---

새로운 커밋으로 이전 커밋을 되돌린다. 히스토리 유지.

| 명령어 | 설명 |
|--------|------|
| `git revert <커밋>` | 특정 커밋 되돌리기 |
| `git revert HEAD` | 마지막 커밋 되돌리기 |
| `git revert -n <커밋>` | 커밋 없이 되돌리기 |
| `git revert HEAD~3..HEAD` | 여러 커밋 되돌리기 |
| `git revert --continue` | 충돌 해결 후 계속 |
| `git revert --abort` | 취소 |
| `git revert -m 1 <머지커밋>` | 머지 커밋 되돌리기 |

## 머지 커밋 되돌리기

```bash
# -m 1: 첫 번째 부모(main) 기준으로 되돌리기
git revert -m 1 <머지커밋해시>
```

> [!info] 협업 시 안전
> revert는 히스토리를 추가하므로 push된 커밋에 안전하게 사용 가능.
