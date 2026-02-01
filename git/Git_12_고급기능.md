# Git 고급 기능

#git #git/고급 #git/worktree #git/submodule #git/bisect #git/hooks

---

## 목차

- [[#Worktree|Worktree]]
- [[#Submodule|Submodule]]
- [[#Bisect|Bisect]]
- [[#Hooks|Hooks]]
- [[#기타 유용한 명령어|기타 유용한 명령어]]

---

## Worktree

하나의 저장소에서 여러 작업 디렉토리를 관리합니다.

| 명령어 | 설명 |
|--------|------|
| `git worktree add <경로> <브랜치>` | 워크트리 추가 |
| `git worktree add -b <새브랜치> <경로>` | 새 브랜치로 워크트리 생성 |
| `git worktree list` | 워크트리 목록 |
| `git worktree remove <경로>` | 워크트리 제거 |
| `git worktree prune` | 삭제된 워크트리 정리 |
| `git worktree lock <경로>` | 워크트리 잠금 |
| `git worktree unlock <경로>` | 워크트리 잠금 해제 |

> [!example] 사용 예시
> ```bash
> # 버그 수정용 워크트리 생성
> git worktree add ../hotfix hotfix/urgent-bug
>
> # 해당 폴더에서 작업
> cd ../hotfix
> # ... 작업 ...
>
> # 작업 완료 후 제거
> git worktree remove ../hotfix
> ```

> [!tip] 활용 시나리오
> - 급한 버그 수정 시 현재 작업을 유지하면서 별도 작업
> - 여러 브랜치 동시 빌드/테스트
> - 코드 리뷰 시 여러 PR 동시 확인

---

## Submodule

다른 Git 저장소를 하위 디렉토리로 포함합니다.

### 추가/초기화

| 명령어 | 설명 |
|--------|------|
| `git submodule add <URL>` | 서브모듈 추가 |
| `git submodule add <URL> <경로>` | 특정 경로에 추가 |
| `git submodule init` | 서브모듈 초기화 |
| `git submodule update` | 서브모듈 업데이트 |
| `git submodule update --init` | 초기화 + 업데이트 |
| `git submodule update --init --recursive` | 재귀적 초기화 |

### 관리

| 명령어 | 설명 |
|--------|------|
| `git submodule status` | 상태 확인 |
| `git submodule foreach <명령>` | 각 서브모듈에서 명령 실행 |
| `git submodule sync` | URL 동기화 |
| `git submodule deinit <경로>` | 서브모듈 등록 해제 |

### 복제 시

```bash
# 서브모듈 포함 복제
git clone --recurse-submodules <URL>

# 이미 복제한 경우
git submodule update --init --recursive
```

> [!warning] 서브모듈 주의사항
> - 서브모듈 변경 후 부모 저장소도 커밋해야 함
> - 브랜치 전환 시 서브모듈 상태 확인 필요
> - 복잡한 의존성에는 패키지 매니저 고려

---

## Bisect

이진 탐색으로 버그가 도입된 커밋을 찾습니다.

### 기본 사용법

| 명령어 | 설명 |
|--------|------|
| `git bisect start` | bisect 시작 |
| `git bisect bad` | 현재 커밋에 버그 있음 |
| `git bisect good <커밋>` | 해당 커밋은 정상 |
| `git bisect reset` | bisect 종료 |
| `git bisect skip` | 현재 커밋 건너뛰기 |
| `git bisect log` | bisect 로그 |
| `git bisect visualize` | 시각화 |

### 워크플로우

```bash
# 1. 시작
git bisect start

# 2. 현재(버그 있음) 표시
git bisect bad

# 3. 정상이었던 커밋 표시
git bisect good v1.0.0

# 4. Git이 중간 커밋을 체크아웃
# 테스트 후 good/bad 표시
git bisect good  # 또는 git bisect bad

# 5. 반복하면 원인 커밋 찾음
# abc1234 is the first bad commit

# 6. 종료
git bisect reset
```

### 자동화

```bash
# 테스트 스크립트로 자동 탐색
git bisect start HEAD v1.0.0
git bisect run ./test.sh

# test.sh: 정상이면 0, 버그면 1 반환
```

---

## Hooks

특정 Git 이벤트에 스크립트를 실행합니다.

### 클라이언트 훅

| 훅 | 시점 |
|----|------|
| `pre-commit` | 커밋 전 |
| `prepare-commit-msg` | 커밋 메시지 생성 후 |
| `commit-msg` | 커밋 메시지 입력 후 |
| `post-commit` | 커밋 완료 후 |
| `pre-push` | push 전 |
| `post-checkout` | checkout 후 |
| `post-merge` | merge 후 |

### 서버 훅

| 훅 | 시점 |
|----|------|
| `pre-receive` | push 수신 전 |
| `update` | 각 브랜치 업데이트 전 |
| `post-receive` | push 완료 후 |

### 훅 설정

```bash
# 훅 디렉토리
ls .git/hooks/

# 훅 활성화 (실행 권한 부여)
chmod +x .git/hooks/pre-commit
```

> [!example] pre-commit 예시
> ```bash
> #!/bin/sh
> # .git/hooks/pre-commit
>
> # 린트 검사
> npm run lint
> if [ $? -ne 0 ]; then
>   echo "Lint 오류! 커밋 취소"
>   exit 1
> fi
> ```

> [!tip] 훅 관리 도구
> - **Husky**: Node.js 프로젝트용
> - **pre-commit**: Python 기반
> - **lefthook**: Go 기반

---

## 기타 유용한 명령어

### 저장소 관리

| 명령어 | 설명 |
|--------|------|
| `git gc` | 가비지 컬렉션 |
| `git gc --aggressive` | 강력한 최적화 |
| `git prune` | 연결 없는 객체 삭제 |
| `git fsck` | 무결성 검사 |
| `git count-objects -vH` | 저장소 크기 확인 |

### 아카이브

| 명령어 | 설명 |
|--------|------|
| `git archive HEAD -o file.zip` | ZIP 생성 |
| `git archive --format=tar HEAD > file.tar` | TAR 생성 |
| `git archive --prefix=project/ HEAD -o file.zip` | 접두사 포함 |

### 커밋 정보

| 명령어 | 설명 |
|--------|------|
| `git rev-parse HEAD` | 현재 커밋 해시 |
| `git rev-parse --short HEAD` | 축약 해시 |
| `git rev-parse --abbrev-ref HEAD` | 현재 브랜치명 |
| `git describe` | 가장 가까운 태그 기반 설명 |
| `git describe --tags` | 경량 태그 포함 |

### 파일 추적

| 명령어 | 설명 |
|--------|------|
| `git ls-files` | 추적 중인 파일 목록 |
| `git ls-files --others` | 추적되지 않는 파일 |
| `git ls-files --ignored` | 무시된 파일 |
| `git ls-tree HEAD` | 트리 구조 |
| `git cat-file -p <해시>` | 객체 내용 확인 |

### 기여 통계

| 명령어 | 설명 |
|--------|------|
| `git shortlog -sn` | 작성자별 커밋 수 |
| `git shortlog -sn --all` | 모든 브랜치 포함 |
| `git log --format='%aN' \| sort \| uniq -c` | 상세 통계 |

---

## 관련 문서

- [[Git_MOC|Git MOC로 돌아가기]]
- [[Git_11_Diff|이전: 차이점 비교]]

---

*마지막 업데이트: 2026-02-01*
