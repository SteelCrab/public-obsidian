# checkout vs switch

#git #개념 #checkout #switch

---

Git 2.23에서 `switch`와 `restore`가 추가되었다.
기존 `checkout`의 역할이 분리됨.

## 역할 비교

| 작업 | 기존 (checkout) | 신규 |
|------|----------------|------|
| 브랜치 전환 | `git checkout <브랜치>` | `git switch <브랜치>` |
| 브랜치 생성+전환 | `git checkout -b <브랜치>` | `git switch -c <브랜치>` |
| 파일 복원 | `git checkout -- <파일>` | `git restore <파일>` |
| 특정 커밋에서 복원 | `git checkout <커밋> -- <파일>` | `git restore --source=<커밋> <파일>` |

## 왜 분리했나?

`checkout`은 브랜치 전환과 파일 복원 두 가지 역할을 했다.
이로 인해 실수로 파일을 덮어쓰는 사고가 발생할 수 있었다.

> [!tip] 추천
> 새 명령어 `switch`와 `restore`를 사용하자.
> 더 명확하고 실수할 가능성이 적다.
