# Git Stash

#git #git/stash #git/임시저장

---

## 목차

- [[#Stash 저장|Stash 저장]]
- [[#Stash 조회|Stash 조회]]
- [[#Stash 적용|Stash 적용]]
- [[#Stash 삭제|Stash 삭제]]
- [[#고급 사용법|고급 사용법]]

---

## Stash 저장

| 명령어 | 설명 |
|--------|------|
| `git stash` | 변경사항 임시 저장 |
| `git stash push` | 변경사항 임시 저장 (명시적) |
| `git stash push -m "메시지"` | 메시지와 함께 저장 |
| `git stash -u` | untracked 파일 포함 |
| `git stash --include-untracked` | `-u`의 풀네임 |
| `git stash -a` | ignored 파일도 포함 |
| `git stash --all` | `-a`의 풀네임 |
| `git stash -k` | staged 변경은 유지 |
| `git stash --keep-index` | `-k`의 풀네임 |
| `git stash push -m "msg" -- <파일>` | 특정 파일만 stash |
| `git stash -p` | 대화형 stash |

> [!example] 사용 예시
> ```bash
> # 작업 중 급한 버그 수정이 필요할 때
> git stash push -m "feature 작업 중"
>
> # 버그 수정
> git checkout main
> # ... 버그 수정 작업 ...
> git commit -m "fix: 긴급 버그 수정"
>
> # 다시 작업으로 돌아오기
> git checkout feature
> git stash pop
> ```

---

## Stash 조회

| 명령어 | 설명 |
|--------|------|
| `git stash list` | stash 목록 |
| `git stash show` | 최근 stash 요약 |
| `git stash show -p` | 최근 stash diff |
| `git stash show stash@{1}` | 특정 stash 요약 |
| `git stash show -p stash@{1}` | 특정 stash diff |

### Stash 인덱스

```
stash@{0}  # 가장 최근
stash@{1}  # 두 번째
stash@{2}  # 세 번째
...
```

---

## Stash 적용

| 명령어 | 설명 |
|--------|------|
| `git stash pop` | 적용 후 삭제 |
| `git stash apply` | 적용 (삭제 안 함) |
| `git stash pop stash@{1}` | 특정 stash 적용 후 삭제 |
| `git stash apply stash@{1}` | 특정 stash 적용 |
| `git stash pop --index` | staged 상태도 복원 |
| `git stash apply --index` | staged 상태도 복원 |

> [!info] pop vs apply
> - **pop**: 적용 후 stash에서 삭제
> - **apply**: 적용만 하고 stash 유지
>
> 충돌이 발생할 수 있다면 apply를 먼저 사용하세요.

---

## Stash 삭제

| 명령어 | 설명 |
|--------|------|
| `git stash drop` | 최근 stash 삭제 |
| `git stash drop stash@{1}` | 특정 stash 삭제 |
| `git stash clear` | 모든 stash 삭제 |

> [!warning] clear 주의
> `git stash clear`는 모든 stash를 삭제합니다.
> 복구가 불가능하니 신중하게 사용하세요.

---

## 고급 사용법

### Stash에서 브랜치 생성

```bash
git stash branch <브랜치명>
# stash 내용으로 새 브랜치 생성 후 자동 적용
```

> [!tip] 사용 시나리오
> stash를 저장한 후 원본 브랜치가 많이 변경되어
> 충돌이 예상될 때 유용합니다.

### 부분 Stash

```bash
# 대화형으로 선택
git stash -p

# 특정 파일만
git stash push -m "메시지" -- file1.js file2.js

# 특정 폴더만
git stash push -m "메시지" -- src/
```

### Untracked 파일만 Stash

```bash
# untracked만 저장하는 직접적인 방법은 없음
# 대신 다음처럼 사용
git stash -u  # tracked + untracked
```

### Stash 비교

```bash
# stash와 현재 브랜치 비교
git diff stash@{0}

# stash와 특정 커밋 비교
git diff stash@{0} HEAD

# 두 stash 비교
git diff stash@{0} stash@{1}
```

---

## 워크플로우 예시

### 1. 급한 작업 처리

```bash
# 현재 작업 저장
git stash push -m "WIP: 로그인 기능"

# 급한 작업으로 전환
git checkout main
git checkout -b hotfix/urgent-bug
# ... 작업 ...
git commit -m "fix: 긴급 버그 수정"
git checkout main
git merge hotfix/urgent-bug
git push

# 원래 작업으로 복귀
git checkout feature/login
git stash pop
```

### 2. 브랜치 이동 시

```bash
# 현재 변경사항 저장
git stash

# 다른 브랜치로 이동
git checkout other-branch

# 작업 후 원래 브랜치로
git checkout original-branch
git stash pop
```

---

## 관련 문서

- [[Git_MOC|Git MOC로 돌아가기]]
- [[Git_08_로그_히스토리|이전: 로그 및 히스토리]]
- [[Git_10_태그|다음: 태그]]

---

*마지막 업데이트: 2026-02-01*
