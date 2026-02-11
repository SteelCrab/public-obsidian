# Git 브랜치 이름 변경

#git #branch #rename

---

브랜치의 이름을 변경한다.

| 명령어 | 설명 |
|--------|------|
| `git branch -m <새이름>` | 현재 브랜치 이름 변경 |
| `git branch -m <기존> <새이름>` | 특정 브랜치 이름 변경 |
| `git branch -M <새이름>` | 강제 이름 변경 |

## 원격 브랜치 이름 변경

원격에는 직접 rename이 없으므로 삭제 후 재생성한다.

```bash
# 1. 로컬 브랜치 이름 변경
git branch -m old-name new-name

# 2. 원격의 이전 브랜치 삭제
git push origin --delete old-name

# 3. 새 브랜치 푸시
git push origin -u new-name
```
