# Git Worktree

#git #worktree #고급

---

하나의 저장소에서 여러 작업 디렉토리를 관리한다.

| 명령어 | 설명 |
|--------|------|
| `git worktree add <경로> <브랜치>` | 워크트리 추가 |
| `git worktree add -b <새브랜치> <경로>` | 새 브랜치로 생성 |
| `git worktree list` | 워크트리 목록 |
| `git worktree remove <경로>` | 워크트리 제거 |
| `git worktree prune` | 삭제된 워크트리 정리 |

## 사용 예시

```bash
# 버그 수정용 워크트리 생성
git worktree add ../hotfix hotfix/urgent-bug

# 해당 폴더에서 작업
cd ../hotfix
# ... 수정 ...

# 작업 완료 후 제거
git worktree remove ../hotfix
```

## 활용 시나리오

- 급한 버그 수정 (현재 작업 유지)
- 여러 브랜치 동시 빌드/테스트
- PR 리뷰 시 여러 브랜치 동시 확인

> [!tip] stash와 비교
> stash: 변경사항 임시 저장
> worktree: 별도 디렉토리에서 병렬 작업
