# Git 되돌리기

#git #git/되돌리기 #git/reset #git/revert #git/restore

---

## 목차

- [[#Reset|Reset]]
- [[#Revert|Revert]]
- [[#Restore|Restore]]
- [[#Clean|Clean]]
- [[#Checkout (파일 복원)|Checkout (파일 복원)]]

---

## Reset

히스토리를 수정하여 되돌립니다. (주의 필요)

| 명령어 | 설명 |
|--------|------|
| `git reset <파일>` | 스테이징 취소 |
| `git reset` | 모든 스테이징 취소 |
| `git reset HEAD~1` | 마지막 커밋 취소 (mixed) |
| `git reset --soft HEAD~1` | 커밋 취소 (스테이징 유지) |
| `git reset --mixed HEAD~1` | 커밋 취소 (스테이징 해제) |
| `git reset --hard HEAD~1` | 커밋 완전 삭제 |
| `git reset --hard origin/main` | 원격과 동기화 |
| `git reset --hard <커밋>` | 특정 커밋으로 되돌리기 |

### Reset 모드 비교

| 모드 | 커밋 | 스테이징 | 작업 디렉토리 |
|------|------|----------|---------------|
| `--soft` | 취소 | 유지 | 유지 |
| `--mixed` (기본) | 취소 | 취소 | 유지 |
| `--hard` | 취소 | 취소 | 취소 |

> [!danger] --hard 주의사항
> 작업 디렉토리의 변경사항이 완전히 삭제됩니다.
> 복구가 어려우니 신중하게 사용하세요.

---

## Revert

새로운 커밋으로 되돌립니다. (히스토리 유지)

| 명령어 | 설명 |
|--------|------|
| `git revert <커밋>` | 특정 커밋 되돌리기 |
| `git revert HEAD` | 마지막 커밋 되돌리기 |
| `git revert --no-commit <커밋>` | 커밋 없이 되돌리기 |
| `git revert -n <커밋>` | `--no-commit` 축약 |
| `git revert HEAD~3..HEAD` | 여러 커밋 되돌리기 |
| `git revert --continue` | 충돌 해결 후 계속 |
| `git revert --abort` | revert 취소 |
| `git revert -m 1 <머지커밋>` | 머지 커밋 되돌리기 |

> [!info] Reset vs Revert
> - **Reset**: 히스토리 수정 (로컬 작업용)
> - **Revert**: 히스토리 유지 (협업 시 안전)
>
> 이미 push한 커밋은 revert를 사용하세요.

---

## Restore

Git 2.23에서 추가된 파일 복원 전용 명령어입니다.

| 명령어 | 설명 |
|--------|------|
| `git restore <파일>` | 작업 디렉토리 변경 취소 |
| `git restore .` | 모든 변경 취소 |
| `git restore --staged <파일>` | 스테이징 취소 |
| `git restore --staged .` | 모든 스테이징 취소 |
| `git restore --source=HEAD~1 <파일>` | 특정 커밋에서 복원 |
| `git restore --source=<브랜치> <파일>` | 다른 브랜치에서 복원 |
| `git restore -SW` | staged + worktree 모두 복원 |

---

## Clean

추적되지 않는 파일 삭제

| 명령어 | 설명 |
|--------|------|
| `git clean -n` | 삭제될 파일 미리보기 |
| `git clean -f` | 파일 삭제 |
| `git clean -fd` | 파일 + 디렉토리 삭제 |
| `git clean -fx` | .gitignore 파일도 삭제 |
| `git clean -fdx` | 전부 삭제 (빌드 파일 포함) |
| `git clean -i` | 대화형 모드 |

> [!warning] clean 사용 전
> 항상 `-n` 옵션으로 미리 확인하세요.
> ```bash
> git clean -n   # 확인
> git clean -f   # 삭제
> ```

---

## Checkout (파일 복원)

| 명령어 | 설명 |
|--------|------|
| `git checkout -- <파일>` | 파일 변경 취소 |
| `git checkout -- .` | 모든 변경 취소 |
| `git checkout <커밋> -- <파일>` | 특정 커밋에서 파일 복원 |

> [!tip] 권장 사항
> 파일 복원에는 `restore` 명령어를 사용하세요.
> `checkout`은 브랜치 전환에도 사용되어 혼란스러울 수 있습니다.

---

## 실수 복구 시나리오

### 1. 방금 한 커밋 취소하고 싶을 때
```bash
git reset --soft HEAD~1  # 변경사항은 유지
```

### 2. 스테이징한 파일 취소하고 싶을 때
```bash
git restore --staged <파일>
```

### 3. 파일 변경 취소하고 싶을 때
```bash
git restore <파일>
```

### 4. 이미 push한 커밋 되돌리고 싶을 때
```bash
git revert <커밋해시>
git push
```

### 5. 모든 것을 원격 상태로 되돌리고 싶을 때
```bash
git fetch origin
git reset --hard origin/main
git clean -fd
```

---

## 관련 문서

- [[Git_MOC|Git MOC로 돌아가기]]
- [[Git_06_병합_리베이스|이전: 병합 및 리베이스]]
- [[Git_08_로그_히스토리|다음: 로그 및 히스토리]]

---

*마지막 업데이트: 2026-02-01*
