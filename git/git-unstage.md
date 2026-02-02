# Git 스테이징 취소

#git #unstage #reset #restore

---

스테이징 영역에 추가한 파일을 다시 작업 디렉토리로 되돌린다.

| 명령어 | 설명 |
|--------|------|
| `git reset <파일>` | 특정 파일 스테이징 취소 |
| `git reset` | 모든 스테이징 취소 |
| `git restore --staged <파일>` | 스테이징 취소 (신규 명령어) |
| `git restore --staged .` | 모든 스테이징 취소 |

> [!tip] reset vs restore
> `restore --staged`가 더 명확하고 안전하다.
> `reset`은 다른 용도로도 사용되어 혼란스러울 수 있다.

---

## 연결 노트

- [[git-add]] - 스테이징하기
- [[git-restore]] - 파일 복원
- [[git-reset]] - reset 전체
- [[Git_MOC]]
