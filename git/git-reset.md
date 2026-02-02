# Git Reset

#git #reset #되돌리기

---

히스토리를 수정하여 커밋을 되돌린다.

| 명령어                            | 설명                |
| ------------------------------ | ----------------- |
| `git reset HEAD~1`             | 마지막 커밋 취소 (mixed) |
| `git reset --soft HEAD~1`      | 커밋 취소, 스테이징 유지    |
| `git reset --mixed HEAD~1`     | 커밋+스테이징 취소        |
| `git reset --hard HEAD~1`      | 모든 변경 삭제          |
| `git reset --hard origin/main` | 원격과 동기화           |
| `git reset <파일>`               | 스테이징 취소           |

## Reset 모드 비교

| 모드        | 커밋  | 스테이징 | 작업 디렉토리 |
| --------- | --- | ---- | ------- |
| `--soft`  | 취소  | 유지   | 유지      |
| `--mixed` | 취소  | 취소   | 유지      |
| `--hard`  | 취소  | 취소   | 취소      |

> [!danger] --hard 주의
> 작업 디렉토리 변경사항이 완전히 삭제된다.
> 복구 어려움.

---

## 연결 노트

- [[git-reset-vs-revert]] - reset vs revert
- [[git-revert]] - revert
- [[git-reflog]] - reset 복구
- [[git-unstage]] - 스테이징 취소
- [[Git_MOC]]
