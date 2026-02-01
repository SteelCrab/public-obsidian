# Git Reflog

#git #reflog #복구

---

HEAD 이동 이력을 기록한다. 실수 복구에 유용.

| 명령어 | 설명 |
|--------|------|
| `git reflog` | HEAD 변경 이력 |
| `git reflog show <브랜치>` | 특정 브랜치 이력 |
| `git reflog -n 10` | 최근 10개만 |

## 출력 예시

```
abc1234 HEAD@{0}: commit: 최신 커밋
def5678 HEAD@{1}: reset: moving to HEAD~1
ghi9012 HEAD@{2}: commit: 삭제된 커밋
```

## 복구 예시

```bash
# 실수로 reset --hard 한 경우
git reflog
# ghi9012 HEAD@{2}: commit: 중요한 작업

git reset --hard ghi9012  # 복구!
```

> [!info] 로컬 전용
> reflog는 로컬에만 저장된다.
> 기본 90일 후 삭제.

---

## 연결 노트

- [[git-reset]] - reset
- [[git-undo-scenarios]] - 복구 시나리오
- [[git-log]] - 일반 로그
- [[Git_MOC]]
