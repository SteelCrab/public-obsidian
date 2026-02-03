# Git 브랜치 삭제

#git #branch #삭제

---

더 이상 필요 없는 브랜치를 삭제한다.

| 명령어 | 설명 |
|--------|------|
| `git branch -d <브랜치명>` | 병합된 브랜치 삭제 |
| `git branch -D <브랜치명>` | 강제 삭제 |
| `git push origin --delete <브랜치>` | 원격 브랜치 삭제 |
| `git push origin :<브랜치>` | 원격 삭제 (축약) |

> [!danger] -D 옵션 주의
> 병합되지 않은 변경사항도 삭제된다.
> 데이터 손실에 주의.

## 병합된 브랜치 정리

```bash
# 병합된 브랜치 확인
git branch --merged

# 병합된 브랜치 한번에 삭제 (main 제외)
git branch --merged | grep -v main | xargs git branch -d
```

---

## 연결 노트

- [[git-branch-list]] - 브랜치 조회
- [[git-merge]] - 브랜치 병합
- [[git-remote]] - 원격 브랜치 관리
- [[Git_MOC]]
