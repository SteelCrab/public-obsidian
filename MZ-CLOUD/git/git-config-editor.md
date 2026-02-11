# Git 에디터 설정

#git #config #에디터

---

커밋 메시지 작성, 리베이스 등에서 사용할 에디터를 지정한다.

| 명령어 | 설명 |
|--------|------|
| `git config --global core.editor "vim"` | Vim |
| `git config --global core.editor "code --wait"` | VS Code |
| `git config --global core.editor "nano"` | Nano |

> [!info] --wait 옵션
> VS Code는 `--wait` 없이 실행하면 Git이 에디터가 닫혔다고 인식한다.
