# Git 원격 저장소 관리

#git #remote #원격

---

원격 저장소를 추가, 조회, 수정한다.

| 명령어                             | 설명            |
| ------------------------------- | ------------- |
| `git remote`                    | 원격 저장소 목록     |
| `git remote -v`                 | URL 포함 목록     |
| `git remote add <이름> <URL>`     | 원격 저장소 추가     |
| `git remote remove <이름>`        | 원격 저장소 삭제     |
| `git remote rename <기존> <새이름>`  | 이름 변경         |
| `git remote set-url <이름> <URL>` | URL 변경        |
| `git remote show <이름>`          | 상세 정보         |
| `git remote prune <이름>`         | 삭제된 원격 브랜치 정리 |

---
## 다중 원격 저장소

```bash
# GitHub과 GitLab 동시 사용
git remote add github https://github.com/user/repo.git
git remote add gitlab https://gitlab.com/user/repo.git

# 각각 push
git push github main
git push gitlab main
```
