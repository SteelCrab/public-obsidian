# Git 실수 복구 시나리오

#git #undo #시나리오

---

상황별 되돌리기 방법 모음.

## 1. 방금 한 커밋 취소

```bash
# 변경사항은 유지하고 커밋만 취소
git reset --soft HEAD~1
```

## 2. 스테이징 취소

```bash
git restore --staged <파일>
# 또는
git reset <파일>
```

## 3. 파일 변경 취소

```bash
git restore <파일>
# 또는
git checkout -- <파일>
```

## 4. push한 커밋 되돌리기

```bash
git revert <커밋해시>
git push
```

## 5. 원격과 완전히 동기화

```bash
git fetch origin
git reset --hard origin/main
git clean -fd
```

## 6. 실수로 삭제한 브랜치 복구

```bash
git reflog  # 삭제 전 커밋 찾기
git checkout -b <브랜치명> <커밋해시>
```

## 7. reset --hard 복구

```bash
git reflog
# abc1234 HEAD@{2}: commit: 중요한 작업
git reset --hard abc1234
```
