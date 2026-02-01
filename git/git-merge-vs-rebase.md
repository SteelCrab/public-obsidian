# merge vs rebase

#git #개념 #merge #rebase

---

두 가지 브랜치 통합 방식의 차이.

## 비교

| | merge | rebase |
|-|-------|--------|
| 히스토리 | 분기 유지, merge 커밋 생성 | 선형으로 정리 |
| 커밋 해시 | 유지 | 변경됨 |
| 협업 안전성 | 안전 | 주의 필요 |
| 되돌리기 | 쉬움 | 어려움 |

## 시각적 비교

```
# merge 후
      A---B---C feature
     /         \
D---E---F---G---H main

# rebase 후
D---E---F---G---A'--B'--C' main
```

## 언제 무엇을 사용?

**merge:**
- 공유 브랜치 (main, develop)
- 히스토리 보존이 중요할 때
- 협업 중인 브랜치

**rebase:**
- 개인 feature 브랜치 정리
- 깔끔한 히스토리 원할 때
- push 전 로컬 커밋 정리

> [!warning] 황금률
> **이미 push한 커밋은 rebase 하지 않는다**

---

## 연결 노트

- [[git-merge]] - merge 상세
- [[git-rebase]] - rebase 상세
- [[git-rebase-interactive]] - 대화형 리베이스
- [[Git_MOC]]
