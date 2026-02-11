# Git 태그 체크아웃

#git #tag #checkout

---

특정 태그 버전으로 이동한다.

| 명령어 | 설명 |
|--------|------|
| `git checkout <태그명>` | 태그로 체크아웃 |
| `git checkout -b <브랜치> <태그명>` | 태그 기반 브랜치 생성 |
| `git switch --detach <태그명>` | 태그로 전환 (신규) |
| `git switch -c <브랜치> <태그명>` | 태그 기반 브랜치 (신규) |

## Detached HEAD 상태

태그를 직접 체크아웃하면 detached HEAD가 된다.

```
You are in 'detached HEAD' state...
```

> [!warning] 주의
> detached HEAD에서 커밋하면 브랜치에 속하지 않는다.
> 작업하려면 브랜치를 생성하자.

```bash
# 태그에서 수정 작업이 필요하면
git checkout -b release-fix v1.0.0
```
