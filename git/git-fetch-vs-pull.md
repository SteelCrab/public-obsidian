# fetch vs pull

#git #개념 #fetch #pull

---

두 명령어의 차이점을 이해하자.

| | fetch | pull |
|-|-------|------|
| 동작 | 원격 → 로컬 저장소 | 원격 → 로컬 저장소 → 작업 디렉토리 |
| 병합 | 수동 | 자동 |
| 안전성 | 안전 | 충돌 가능 |
| 수식 | `fetch` | `fetch + merge` |

## 언제 무엇을 사용?

**fetch 사용:**
- 원격 변경사항을 먼저 확인하고 싶을 때
- 충돌이 예상될 때
- 코드 리뷰 후 병합하고 싶을 때

**pull 사용:**
- 빠르게 최신 코드를 받고 싶을 때
- 충돌 가능성이 낮을 때

## 안전한 워크플로우

```bash
# 1. 먼저 fetch
git fetch

# 2. 차이 확인
git log HEAD..origin/main

# 3. 이상 없으면 병합
git merge origin/main
```

---

## 연결 노트

- [[git-fetch]] - fetch 상세
- [[git-pull]] - pull 상세
- [[git-merge]] - 병합
- [[Git_MOC]]
