# Git 대화형 리베이스

#git #rebase #interactive

---

과거 커밋을 수정, 합치기, 삭제한다.

| 명령어 | 설명 |
|--------|------|
| `git rebase -i HEAD~3` | 최근 3개 커밋 수정 |
| `git rebase -i <커밋>` | 특정 커밋부터 수정 |

## 대화형 명령어

| 명령어 | 축약 | 설명 |
|--------|------|------|
| `pick` | p | 커밋 그대로 사용 |
| `reword` | r | 커밋 메시지 수정 |
| `edit` | e | 커밋 내용 수정 |
| `squash` | s | 이전 커밋과 합치기 (메시지 합침) |
| `fixup` | f | 이전 커밋과 합치기 (메시지 버림) |
| `drop` | d | 커밋 삭제 |

## 예시

```bash
git rebase -i HEAD~3

# 에디터에서:
pick abc1234 첫 번째 커밋
squash def5678 두 번째 커밋
reword ghi9012 세 번째 커밋
```

> [!tip] 활용 시나리오
> - 커밋 메시지 오타 수정
> - WIP 커밋들 하나로 합치기
> - 실수로 넣은 커밋 삭제

---

## 연결 노트

- [[git-rebase]] - 리베이스 기본
- [[git-commit]] - 커밋 (amend)
- [[git-push-force]] - 수정 후 강제 푸시
- [[Git_MOC]]
