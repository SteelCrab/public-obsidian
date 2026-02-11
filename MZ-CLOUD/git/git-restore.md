# Git Restore

#git #restore #복원

---

작업 디렉토리나 스테이징 영역의 파일을 복원한다. (Git 2.23+)

| 명령어 | 설명 |
|--------|------|
| `git restore <파일>` | 작업 디렉토리 변경 취소 |
| `git restore .` | 모든 변경 취소 |
| `git restore --staged <파일>` | 스테이징 취소 |
| `git restore --staged .` | 모든 스테이징 취소 |
| `git restore --source=HEAD~1 <파일>` | 특정 커밋에서 복원 |
| `git restore --source=<브랜치> <파일>` | 다른 브랜치에서 복원 |
| `git restore -SW` | staged + worktree 모두 복원 |

## 기존 명령어와 비교

| 작업 | 기존 | 신규 |
|------|------|------|
| 파일 변경 취소 | `git checkout -- <파일>` | `git restore <파일>` |
| 스테이징 취소 | `git reset <파일>` | `git restore --staged <파일>` |

> [!tip] restore 권장
> checkout이나 reset보다 용도가 명확하다.
