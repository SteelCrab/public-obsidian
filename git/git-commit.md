# Git 커밋

#git #commit #커밋

---

스테이징된 변경사항을 저장소에 기록한다.

| 명령어 | 설명 |
|--------|------|
| `git commit` | 에디터에서 메시지 작성 |
| `git commit -m "메시지"` | 인라인 메시지 |
| `git commit -am "메시지"` | add + commit (추적 파일만) |
| `git commit -v` | diff 보면서 커밋 |
| `git commit --allow-empty -m "메시지"` | 빈 커밋 생성 |

## 커밋 수정 (amend)

| 명령어 | 설명 |
|--------|------|
| `git commit --amend` | 마지막 커밋 수정 |
| `git commit --amend -m "새 메시지"` | 메시지만 수정 |
| `git commit --amend --no-edit` | 파일만 추가 |

> [!warning] amend 주의
> 이미 push한 커밋을 amend하면 force push가 필요하다.
> 협업 시 주의.

---

## 연결 노트

- [[git-add]] - 스테이징
- [[git-reset]] - 커밋 취소
- [[git-rebase-interactive]] - 과거 커밋 수정
- [[git-log]] - 커밋 히스토리
- [[Git_MOC]]
