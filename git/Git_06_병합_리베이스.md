# Git 병합 및 리베이스

#git #git/병합 #git/merge #git/rebase #git/cherry-pick

---

## 목차

- [[#Merge|Merge]]
- [[#Rebase|Rebase]]
- [[#Cherry-pick|Cherry-pick]]
- [[#충돌 해결|충돌 해결]]

---

## Merge

| 명령어 | 설명 |
|--------|------|
| `git merge <브랜치>` | 브랜치 병합 |
| `git merge --no-ff <브랜치>` | fast-forward 없이 병합 |
| `git merge --ff-only <브랜치>` | fast-forward만 허용 |
| `git merge --squash <브랜치>` | 커밋 합쳐서 병합 |
| `git merge --no-commit <브랜치>` | 자동 커밋 없이 병합 |
| `git merge --abort` | 병합 취소 |

### Merge 전략

```bash
# 기본 병합 (3-way merge)
git merge feature

# merge 커밋 항상 생성
git merge --no-ff feature

# 하나의 커밋으로 합치기
git merge --squash feature
git commit -m "Merge feature branch"
```

> [!info] --no-ff 사용 이유
> 히스토리에서 브랜치 병합 지점을 명확히 볼 수 있습니다.
> 팀 작업 시 권장됩니다.

---

## Rebase

| 명령어 | 설명 |
|--------|------|
| `git rebase <브랜치>` | 리베이스 |
| `git rebase main` | main 기준으로 리베이스 |
| `git rebase -i HEAD~3` | 대화형 리베이스 (최근 3개) |
| `git rebase -i <커밋>` | 특정 커밋부터 리베이스 |
| `git rebase --onto <새기준> <이전기준> <브랜치>` | 기준점 변경 리베이스 |
| `git rebase --continue` | 충돌 해결 후 계속 |
| `git rebase --abort` | 리베이스 취소 |
| `git rebase --skip` | 현재 커밋 건너뛰기 |

### 대화형 리베이스 명령어

| 명령어 | 설명 |
|--------|------|
| `pick` (p) | 커밋 그대로 사용 |
| `reword` (r) | 커밋 메시지 수정 |
| `edit` (e) | 커밋 수정 |
| `squash` (s) | 이전 커밋과 합치기 (메시지 합침) |
| `fixup` (f) | 이전 커밋과 합치기 (메시지 버림) |
| `drop` (d) | 커밋 삭제 |

> [!example] 대화형 리베이스 예시
> ```bash
> # 최근 3개 커밋 수정
> git rebase -i HEAD~3
>
> # 에디터에서:
> pick abc1234 첫 번째 커밋
> squash def5678 두 번째 커밋 (첫 번째와 합침)
> reword ghi9012 세 번째 커밋 (메시지 수정)
> ```

> [!warning] Rebase 주의사항
> - 이미 push한 커밋은 rebase하지 마세요
> - 공유된 브랜치에서는 merge를 사용하세요
> - force push가 필요할 수 있습니다

---

## Cherry-pick

| 명령어 | 설명 |
|--------|------|
| `git cherry-pick <커밋>` | 특정 커밋 가져오기 |
| `git cherry-pick <커밋1> <커밋2>` | 여러 커밋 가져오기 |
| `git cherry-pick <시작>..<끝>` | 범위 커밋 가져오기 |
| `git cherry-pick --no-commit <커밋>` | 커밋 없이 변경사항만 |
| `git cherry-pick -n <커밋>` | `--no-commit` 축약 |
| `git cherry-pick --continue` | 충돌 해결 후 계속 |
| `git cherry-pick --abort` | cherry-pick 취소 |

---

## 충돌 해결

### 충돌 발생 시

```bash
# 1. 충돌 파일 확인
git status

# 2. 충돌 해결 (에디터로 수정)
# <<<<<<< HEAD
# 현재 브랜치 내용
# =======
# 병합하려는 브랜치 내용
# >>>>>>> feature

# 3. 충돌 해결 후 스테이징
git add <파일>

# 4. 병합 완료 (merge의 경우)
git commit

# 4. 리베이스 계속 (rebase의 경우)
git rebase --continue
```

### 충돌 해결 도구

| 명령어 | 설명 |
|--------|------|
| `git mergetool` | 병합 도구 실행 |
| `git diff` | 충돌 내용 확인 |
| `git checkout --ours <파일>` | 현재 브랜치 버전 선택 |
| `git checkout --theirs <파일>` | 병합 대상 버전 선택 |

---

## 관련 문서

- [[Git_MOC|Git MOC로 돌아가기]]
- [[Git_05_원격저장소|이전: 원격 저장소]]
- [[Git_07_되돌리기|다음: 되돌리기]]

---

*마지막 업데이트: 2026-02-01*
