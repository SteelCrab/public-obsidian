# Git Hooks

#git #hooks #자동화

---

특정 Git 이벤트에 스크립트를 자동 실행한다.

## 클라이언트 훅

| 훅 | 시점 |
|----|------|
| `pre-commit` | 커밋 전 |
| `prepare-commit-msg` | 커밋 메시지 생성 후 |
| `commit-msg` | 커밋 메시지 입력 후 |
| `post-commit` | 커밋 완료 후 |
| `pre-push` | push 전 |

## 서버 훅

| 훅 | 시점 |
|----|------|
| `pre-receive` | push 수신 전 |
| `update` | 각 브랜치 업데이트 전 |
| `post-receive` | push 완료 후 |

## 훅 설정

```bash
# 훅 디렉토리
ls .git/hooks/

# 실행 권한 부여
chmod +x .git/hooks/pre-commit
```

## pre-commit 예시

```bash
#!/bin/sh
# .git/hooks/pre-commit

npm run lint
if [ $? -ne 0 ]; then
  echo "Lint 오류!"
  exit 1
fi
```

## 훅 관리 도구

- **Husky**: Node.js 프로젝트
- **pre-commit**: Python 기반
- **lefthook**: Go 기반
