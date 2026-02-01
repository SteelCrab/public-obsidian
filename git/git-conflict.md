# Git 충돌 해결

#git #conflict #충돌

---

병합이나 리베이스 시 같은 부분이 다르게 수정되면 충돌이 발생한다.

## 충돌 해결 절차

```bash
# 1. 충돌 파일 확인
git status

# 2. 파일 열어서 충돌 해결
# <<<<<<< HEAD
# 현재 브랜치 내용
# =======
# 병합하려는 브랜치 내용
# >>>>>>> feature

# 3. 마커 제거하고 원하는 내용으로 수정

# 4. 스테이징
git add <파일>

# 5. 완료
git commit        # merge의 경우
git rebase --continue  # rebase의 경우
```

## 충돌 해결 도구

| 명령어 | 설명 |
|--------|------|
| `git mergetool` | 병합 도구 실행 |
| `git diff` | 충돌 내용 확인 |
| `git checkout --ours <파일>` | 현재 브랜치 버전 선택 |
| `git checkout --theirs <파일>` | 대상 브랜치 버전 선택 |

> [!tip] ours vs theirs
> merge: ours=현재, theirs=병합대상
> rebase: ours=리베이스대상, theirs=현재 (반대!)

---

## 연결 노트

- [[git-merge]] - 병합
- [[git-rebase]] - 리베이스
- [[git-cherry-pick]] - 체리픽
- [[git-diff]] - 차이 확인
- [[Git_MOC]]
