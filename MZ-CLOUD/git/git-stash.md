# Git Stash

#git #stash #임시저장

---

작업 중인 변경사항을 임시로 저장한다.

## 저장

| 명령어 | 설명 |
|--------|------|
| `git stash` | 변경사항 임시 저장 |
| `git stash push -m "메시지"` | 메시지와 함께 저장 |
| `git stash -u` | untracked 파일 포함 |
| `git stash -k` | staged 변경은 유지 |
| `git stash push -- <파일>` | 특정 파일만 |
| `git stash -p` | 대화형 stash |

## 조회

| 명령어 | 설명 |
|--------|------|
| `git stash list` | stash 목록 |
| `git stash show` | 최근 stash 요약 |
| `git stash show -p` | 최근 stash diff |

## 적용/삭제

| 명령어 | 설명 |
|--------|------|
| `git stash pop` | 적용 후 삭제 |
| `git stash apply` | 적용 (삭제 안 함) |
| `git stash drop` | 삭제 |
| `git stash clear` | 모든 stash 삭제 |

> [!tip] pop vs apply
> 충돌이 예상되면 apply 먼저 사용.
> 문제없으면 drop.
