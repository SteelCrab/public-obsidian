# Git Stash 워크플로우

#git #stash #workflow

---

stash를 활용한 실제 작업 시나리오.

## 급한 버그 수정

```bash
# 1. 현재 작업 저장
git stash push -m "WIP: 로그인 기능"

# 2. 버그 수정 브랜치로
git checkout main
git checkout -b hotfix/urgent

# 3. 버그 수정 후 병합
git commit -m "fix: 긴급 버그"
git checkout main
git merge hotfix/urgent
git push

# 4. 원래 작업으로 복귀
git checkout feature/login
git stash pop
```

## 브랜치 이동 시

```bash
git stash
git checkout other-branch
# ... 작업 ...
git checkout original-branch
git stash pop
```

## Stash에서 브랜치 생성

```bash
# stash 내용으로 새 브랜치 생성
git stash branch new-feature
# 자동으로 stash 적용 + 브랜치 전환
```

> [!tip] 사용 시나리오
> 원본 브랜치가 많이 바뀌어 충돌이 예상될 때 유용.
