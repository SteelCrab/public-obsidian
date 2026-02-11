# Git Show

#git #show #조회

---

커밋, 태그 등의 상세 정보를 확인한다.

| 명령어 | 설명 |
|--------|------|
| `git show` | 마지막 커밋 상세 |
| `git show <커밋>` | 특정 커밋 상세 |
| `git show <커밋>:<파일>` | 특정 커밋의 파일 내용 |
| `git show --stat <커밋>` | 변경 통계만 |
| `git show --name-only <커밋>` | 파일명만 |
| `git show <태그>` | 태그 정보 |

## 활용

```bash
# 특정 커밋에서 파일 내용 보기
git show abc1234:src/app.js

# 3개 전 커밋의 README
git show HEAD~3:README.md
```
