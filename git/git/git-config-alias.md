# Git 별칭 설정

#git #config #alias

---

자주 쓰는 명령어를 짧게 줄여 사용한다.

| 명령어 | 설명 |
|--------|------|
| `git config --global alias.st status` | `git st` |
| `git config --global alias.co checkout` | `git co` |
| `git config --global alias.br branch` | `git br` |
| `git config --global alias.ci commit` | `git ci` |
| `git config --global alias.lg "log --oneline --graph --all"` | 그래프 로그 |

## 추천 별칭

```bash
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD"
git config --global alias.visual "!gitk"
```

> [!tip] 외부 명령어
> `!`로 시작하면 셸 명령어를 실행할 수 있다.

---

## 연결 노트

- [[git-config-user]] - 사용자 설정
- [[git-config-list]] - 설정 확인
- [[git-log]] - 로그 명령어
- [[Git_MOC]]
