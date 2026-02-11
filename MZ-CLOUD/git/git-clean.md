# Git Clean

#git #clean #정리

---

추적되지 않는(untracked) 파일을 삭제한다.

| 명령어 | 설명 |
|--------|------|
| `git clean -n` | 삭제될 파일 미리보기 |
| `git clean -f` | 파일 삭제 |
| `git clean -fd` | 파일 + 디렉토리 삭제 |
| `git clean -fx` | .gitignore 파일도 삭제 |
| `git clean -fdx` | 전부 삭제 (빌드 파일 포함) |
| `git clean -i` | 대화형 모드 |

## 안전한 사용법

```bash
# 항상 먼저 확인!
git clean -n    # 뭐가 삭제될지 확인
git clean -f    # 확인 후 삭제
```

> [!warning] 복구 불가
> 삭제된 untracked 파일은 Git으로 복구할 수 없다.
> 반드시 `-n`으로 먼저 확인.

## 완전 초기화

```bash
# 저장소를 완전히 깨끗한 상태로
git reset --hard HEAD
git clean -fdx
```
