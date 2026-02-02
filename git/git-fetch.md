# Git Fetch

#git #fetch #원격

---

원격 변경사항을 가져오기만 한다. (로컬 변경 X)

| 명령어 | 설명 |
|--------|------|
| `git fetch` | 기본 원격에서 가져오기 |
| `git fetch origin` | 특정 원격에서 가져오기 |
| `git fetch --all` | 모든 원격에서 가져오기 |
| `git fetch --prune` | 삭제된 브랜치 정리 |
| `git fetch -p` | --prune 축약 |
| `git fetch origin <브랜치>` | 특정 브랜치만 |
| `git fetch --tags` | 태그 포함 |
| `git fetch --dry-run` | 실제 실행 없이 확인 |

## fetch 후 확인

```bash
git fetch
git log HEAD..origin/main  # 원격에 있는 새 커밋
git diff HEAD origin/main  # 차이점 확인
git merge origin/main      # 수동 병합
```

---

## 연결 노트

- [[git-fetch-vs-pull]] - fetch vs pull 차이
- [[git-pull]] - 풀
- [[git-merge]] - 병합
- [[Git_MOC]]
