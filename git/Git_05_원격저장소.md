# Git 원격 저장소

#git #git/원격 #git/remote #git/push #git/pull #git/fetch

---

## 목차

- [[#원격 저장소 관리|원격 저장소 관리]]
- [[#Push|Push]]
- [[#Pull|Pull]]
- [[#Fetch|Fetch]]

---

## 원격 저장소 관리

| 명령어 | 설명 |
|--------|------|
| `git remote` | 원격 저장소 목록 |
| `git remote -v` | URL 포함 목록 |
| `git remote add <이름> <URL>` | 원격 저장소 추가 |
| `git remote remove <이름>` | 원격 저장소 삭제 |
| `git remote rename <기존> <새이름>` | 이름 변경 |
| `git remote set-url <이름> <URL>` | URL 변경 |
| `git remote show <이름>` | 상세 정보 |
| `git remote prune <이름>` | 삭제된 원격 브랜치 정리 |

### 다중 원격 저장소 설정

```bash
# GitHub과 GitLab 동시 사용
git remote add github https://github.com/user/repo.git
git remote add gitlab https://gitlab.com/user/repo.git

# 각각 push
git push github main
git push gitlab main
```

---

## Push

| 명령어                              | 설명           |
| -------------------------------- | ------------ |
| `git push`                       | 현재 브랜치 푸시    |
| `git push origin <브랜치>`          | 특정 브랜치 푸시    |
| `git push -u origin <브랜치>`       | 업스트림 설정 후 푸시 |
| `git push --all`                 | 모든 브랜치 푸시    |
| `git push --tags`                | 모든 태그 푸시     |
| `git push origin --delete <브랜치>` | 원격 브랜치 삭제    |

### Force Push

| 명령어 | 설명 |
|--------|------|
| `git push --force` | 강제 푸시 (위험!) |
| `git push -f` | 강제 푸시 축약 |
| `git push --force-with-lease` | 안전한 강제 푸시 |

> [!danger] Force Push 주의사항
> - 다른 사람의 커밋을 덮어쓸 수 있습니다
> - `--force-with-lease` 사용을 권장합니다
> - main/master 브랜치에는 절대 사용하지 마세요

---

## Pull

| 명령어 | 설명 |
|--------|------|
| `git pull` | fetch + merge |
| `git pull origin <브랜치>` | 특정 브랜치 pull |
| `git pull --rebase` | fetch + rebase |
| `git pull --rebase=interactive` | 대화형 리베이스 |
| `git pull --no-commit` | 자동 커밋 없이 |
| `git pull --ff-only` | fast-forward만 허용 |

> [!tip] Pull 전략 설정
> ```bash
> # 기본 전략을 rebase로 설정
> git config --global pull.rebase true
>
> # fast-forward만 허용
> git config --global pull.ff only
> ```

---

## Fetch

| 명령어 | 설명 |
|--------|------|
| `git fetch` | 원격 변경사항 가져오기 |
| `git fetch origin` | 특정 원격에서 가져오기 |
| `git fetch --all` | 모든 원격에서 가져오기 |
| `git fetch --prune` | 삭제된 브랜치 정리 |
| `git fetch -p` | `--prune` 축약 |
| `git fetch origin <브랜치>` | 특정 브랜치만 |
| `git fetch --tags` | 태그 포함 |
| `git fetch --dry-run` | 실제 실행 없이 확인 |

> [!info] fetch vs pull
> - `fetch`: 원격 변경사항만 가져옴 (로컬 변경 X)
> - `pull`: fetch + merge (로컬에 자동 병합)
>
> 안전하게 확인 후 병합하려면 fetch를 먼저 사용하세요.

---

## 관련 문서

- [[Git_MOC|Git MOC로 돌아가기]]
- [[Git_04_브랜치|이전: 브랜치 관리]]
- [[Git_06_병합_리베이스|다음: 병합 및 리베이스]]

---

*마지막 업데이트: 2026-02-01*
