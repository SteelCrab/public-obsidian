# Git Force Push

#git #push #force #위험

---

원격 히스토리를 덮어쓴다. 주의 필요.

| 명령어 | 설명 |
|--------|------|
| `git push --force` | 강제 푸시 |
| `git push -f` | 강제 푸시 (축약) |
| `git push --force-with-lease` | 안전한 강제 푸시 |

## --force vs --force-with-lease

| 옵션 | 동작 |
|------|------|
| `--force` | 무조건 덮어씀 |
| `--force-with-lease` | 원격이 예상과 다르면 거부 |

> [!danger] Force Push 주의
> - 다른 사람의 커밋을 덮어쓸 수 있다
> - main/master 브랜치에는 절대 사용 금지
> - 반드시 `--force-with-lease` 사용 권장

## 언제 사용하나?

- [[git-rebase]] 후 개인 브랜치 업데이트
- `git commit --amend` 후 푸시
- 실수로 올린 민감 정보 제거
