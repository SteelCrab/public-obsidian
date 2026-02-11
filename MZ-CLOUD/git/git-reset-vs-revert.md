# reset vs revert

#git #개념 #reset #revert

---

두 가지 되돌리기 방식의 차이.

## 비교

| | reset | revert |
|-|-------|--------|
| 히스토리 | 수정 (커밋 삭제) | 유지 (새 커밋 추가) |
| 협업 안전성 | 위험 | 안전 |
| push 후 | force push 필요 | 일반 push 가능 |
| 복구 | reflog로 가능 | revert를 revert |

## 시각적 비교

```
# 원본
A---B---C---D (HEAD)

# reset --hard HEAD~2
A---B (HEAD)     # C, D 히스토리에서 사라짐

# revert HEAD~1..HEAD
A---B---C---D---D'---C' (HEAD)  # 되돌리는 커밋 추가
```

## 언제 무엇을 사용?

**reset:**
- 아직 push하지 않은 로컬 커밋
- 개인 브랜치 정리

**revert:**
- 이미 push한 커밋
- 협업 중인 브랜치
- 되돌린 기록을 남기고 싶을 때

> [!tip] 간단한 원칙
> push 전 = reset, push 후 = revert
