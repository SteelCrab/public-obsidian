# Git Cherry-pick

#git #cherry-pick #체리픽

---

특정 커밋만 골라서 현재 브랜치에 적용한다.

| 명령어 | 설명 |
|--------|------|
| `git cherry-pick <커밋>` | 특정 커밋 가져오기 |
| `git cherry-pick <커밋1> <커밋2>` | 여러 커밋 |
| `git cherry-pick <시작>..<끝>` | 범위 커밋 |
| `git cherry-pick -n <커밋>` | 커밋 없이 변경사항만 |
| `git cherry-pick --continue` | 충돌 해결 후 계속 |
| `git cherry-pick --abort` | 취소 |

## 사용 시나리오

```bash
# 다른 브랜치의 버그 수정 커밋만 가져오기
git cherry-pick abc1234

# 여러 커밋 한번에
git cherry-pick abc1234 def5678
```

> [!tip] 활용
> - hotfix를 여러 브랜치에 적용
> - 다른 브랜치의 특정 기능만 가져오기
> - 잘못된 브랜치에 한 커밋 옮기기
