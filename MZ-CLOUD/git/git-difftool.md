# Git Difftool

#git #diff #tool

---

외부 도구로 diff를 시각적으로 비교한다.

## 도구 설정

```bash
# VS Code
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'

# Vim
git config --global diff.tool vimdiff
```

## 사용

| 명령어 | 설명 |
|--------|------|
| `git difftool` | 외부 도구로 diff |
| `git difftool <커밋>` | 특정 커밋과 비교 |
| `git difftool --dir-diff` | 디렉토리 비교 |
| `git difftool -y` | 확인 없이 실행 |

## Mergetool 설정

충돌 해결용 도구 설정.

```bash
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'
```
