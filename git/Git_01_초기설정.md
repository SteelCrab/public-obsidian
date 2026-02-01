# Git 초기 설정

#git #git/설정 #git/config

---

## 목차

- [[#사용자 정보 설정|사용자 정보 설정]]
- [[#에디터 설정|에디터 설정]]
- [[#기본 브랜치 설정|기본 브랜치 설정]]
- [[#별칭 설정|별칭 설정]]
- [[#설정 확인|설정 확인]]

---

## 사용자 정보 설정

| 명령어 | 설명 |
|--------|------|
| `git config --global user.name "이름"` | 전역 사용자 이름 설정 |
| `git config --global user.email "이메일"` | 전역 이메일 설정 |
| `git config user.name "이름"` | 현재 저장소 사용자 이름 |
| `git config user.email "이메일"` | 현재 저장소 이메일 |

---

## 에디터 설정

| 명령어 | 설명 |
|--------|------|
| `git config --global core.editor "vim"` | Vim 설정 |
| `git config --global core.editor "code --wait"` | VS Code 설정 |
| `git config --global core.editor "nano"` | Nano 설정 |

---

## 기본 브랜치 설정

| 명령어 | 설명 |
|--------|------|
| `git config --global init.defaultBranch main` | 기본 브랜치를 main으로 |
| `git config --global init.defaultBranch master` | 기본 브랜치를 master로 |

---

## 별칭 설정

| 명령어 | 설명 |
|--------|------|
| `git config --global alias.st status` | `git st` = `git status` |
| `git config --global alias.co checkout` | `git co` = `git checkout` |
| `git config --global alias.br branch` | `git br` = `git branch` |
| `git config --global alias.ci commit` | `git ci` = `git commit` |
| `git config --global alias.lg "log --oneline --graph --all"` | 그래프 로그 |

> [!tip] 추천 별칭
> ```bash
> git config --global alias.unstage "reset HEAD --"
> git config --global alias.last "log -1 HEAD"
> git config --global alias.visual "!gitk"
> ```

---

## 설정 확인

| 명령어 | 설명 |
|--------|------|
| `git config --list` | 모든 설정 확인 |
| `git config --global --list` | 전역 설정만 확인 |
| `git config user.name` | 특정 설정값 확인 |
| `git config --show-origin user.name` | 설정 파일 위치 확인 |

---

## 관련 문서

- [[Git_MOC|Git MOC로 돌아가기]]
- [[Git_02_저장소|다음: 저장소 생성 및 복제]]

---

*마지막 업데이트: 2026-02-01*
