# Git 브랜치 추적

#git #branch #upstream #추적

---

로컬 브랜치와 원격 브랜치를 연결한다.

| 명령어 | 설명 |
|--------|------|
| `git branch -u origin/<브랜치>` | 업스트림 설정 |
| `git branch --set-upstream-to=origin/<브랜치>` | 업스트림 설정 (풀네임) |
| `git branch --unset-upstream` | 업스트림 해제 |
| `git checkout --track origin/<브랜치>` | 원격 브랜치 추적 |
| `git push -u origin <브랜치>` | push하면서 추적 설정 |

## 추적 상태 확인

```bash
git branch -vv
# * main   abc1234 [origin/main] 메시지
# feature def5678 [origin/feature: ahead 2] 메시지
```

> [!info] ahead/behind
> `ahead 2`: 원격보다 2개 커밋 앞섬
> `behind 3`: 원격보다 3개 커밋 뒤처짐

---

## 연결 노트

- [[git-push]] - 푸시
- [[git-pull]] - 풀
- [[git-fetch]] - 페치
- [[git-remote]] - 원격 저장소
- [[Git_MOC]]
