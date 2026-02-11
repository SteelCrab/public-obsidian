# Git Bisect

#git #bisect #디버깅

---

이진 탐색으로 버그가 도입된 커밋을 찾는다.

| 명령어 | 설명 |
|--------|------|
| `git bisect start` | 시작 |
| `git bisect bad` | 현재 커밋에 버그 있음 |
| `git bisect good <커밋>` | 해당 커밋은 정상 |
| `git bisect reset` | 종료 |
| `git bisect skip` | 현재 커밋 건너뛰기 |

## 워크플로우

```bash
# 1. 시작
git bisect start

# 2. 현재(버그 있음) 표시
git bisect bad

# 3. 정상이었던 커밋 표시
git bisect good v1.0.0

# 4. Git이 중간 커밋 체크아웃
# 테스트 후 good/bad 표시
git bisect good  # 또는 bad

# 5. 반복하면 원인 커밋 찾음
# abc1234 is the first bad commit

# 6. 종료
git bisect reset
```

## 자동화

```bash
# 테스트 스크립트로 자동 탐색
git bisect start HEAD v1.0.0
git bisect run ./test.sh
# test.sh: 정상=0, 버그=1 반환
```
