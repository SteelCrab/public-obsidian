# Git 차이점 비교 (Diff)

#git #git/diff #git/비교

---

## 목차

- [[#기본 Diff|기본 Diff]]
- [[#커밋 간 비교|커밋 간 비교]]
- [[#브랜치 간 비교|브랜치 간 비교]]
- [[#출력 옵션|출력 옵션]]
- [[#Diff 도구|Diff 도구]]

---

## 기본 Diff

| 명령어 | 설명 |
|--------|------|
| `git diff` | 작업 디렉토리 변경사항 |
| `git diff --staged` | 스테이징된 변경사항 |
| `git diff --cached` | `--staged`와 동일 |
| `git diff HEAD` | 모든 변경사항 (staged + unstaged) |
| `git diff -- <파일>` | 특정 파일 변경사항 |
| `git diff -- <폴더>/` | 특정 폴더 변경사항 |

> [!info] staged vs unstaged
> - `git diff`: 아직 스테이징되지 않은 변경
> - `git diff --staged`: 스테이징된 변경 (커밋 예정)

---

## 커밋 간 비교

| 명령어 | 설명 |
|--------|------|
| `git diff <커밋>` | 특정 커밋과 작업 디렉토리 비교 |
| `git diff <커밋> --staged` | 특정 커밋과 스테이징 비교 |
| `git diff <커밋1> <커밋2>` | 두 커밋 비교 |
| `git diff <커밋1>..<커밋2>` | 두 커밋 비교 (동일) |
| `git diff HEAD~3` | 3개 전 커밋과 비교 |
| `git diff HEAD~3..HEAD` | 최근 3개 커밋 변경사항 |
| `git diff HEAD^ HEAD` | 마지막 커밋 변경사항 |

### 범위 표기법

| 표기법 | 의미 |
|--------|------|
| `A..B` | A부터 B까지 변경사항 |
| `A...B` | 공통 조상부터 B까지 |
| `HEAD~1` | 1개 전 커밋 |
| `HEAD~3` | 3개 전 커밋 |
| `HEAD^` | 부모 커밋 |
| `HEAD^2` | 두 번째 부모 (merge commit) |

---

## 브랜치 간 비교

| 명령어 | 설명 |
|--------|------|
| `git diff main feature` | 두 브랜치 비교 |
| `git diff main..feature` | main과 feature 차이 |
| `git diff main...feature` | main에서 분기 후 feature 변경 |
| `git diff origin/main` | 원격 main과 비교 |
| `git diff origin/main..HEAD` | 원격과 로컬 차이 |

> [!info] .. vs ...
> - `main..feature`: main과 feature의 직접 비교
> - `main...feature`: 분기점 이후 feature의 변경만
>
> PR 리뷰 시에는 `...` 가 더 유용합니다.

---

## 출력 옵션

### 통계/요약

| 명령어 | 설명 |
|--------|------|
| `git diff --stat` | 변경 통계 |
| `git diff --shortstat` | 간략한 통계 |
| `git diff --numstat` | 숫자 통계 |
| `git diff --name-only` | 변경된 파일명만 |
| `git diff --name-status` | 파일명 + 상태 |
| `git diff --summary` | 생성/삭제/이름변경 요약 |

### 출력 형식

| 명령어 | 설명 |
|--------|------|
| `git diff --color` | 색상 출력 |
| `git diff --no-color` | 색상 없이 |
| `git diff --color-words` | 단어 단위 색상 |
| `git diff --word-diff` | 단어 단위 diff |
| `git diff --word-diff=color` | 단어 단위 색상 |
| `git diff -U5` | 컨텍스트 5줄 (기본 3) |

### 필터링

| 명령어 | 설명 |
|--------|------|
| `git diff -w` | 공백 변경 무시 |
| `git diff --ignore-space-change` | 공백 양 변경 무시 |
| `git diff --ignore-all-space` | 모든 공백 무시 |
| `git diff --ignore-blank-lines` | 빈 줄 무시 |
| `git diff -M` | 파일 이동 감지 |
| `git diff -C` | 파일 복사 감지 |
| `git diff --diff-filter=M` | 수정된 파일만 |
| `git diff --diff-filter=A` | 추가된 파일만 |
| `git diff --diff-filter=D` | 삭제된 파일만 |

### Diff 필터 옵션

| 옵션 | 의미 |
|------|------|
| `A` | Added |
| `C` | Copied |
| `D` | Deleted |
| `M` | Modified |
| `R` | Renamed |
| `T` | Type changed |
| `U` | Unmerged |

---

## Diff 도구

### 외부 도구 설정

```bash
# difftool 설정
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'

# 또는 vimdiff
git config --global diff.tool vimdiff
```

### 도구 사용

| 명령어 | 설명 |
|--------|------|
| `git difftool` | 외부 diff 도구 실행 |
| `git difftool <커밋>` | 특정 커밋과 비교 |
| `git difftool --dir-diff` | 디렉토리 비교 |
| `git difftool -y` | 확인 없이 실행 |

---

## 실용적인 예시

### PR 검토 전 확인

```bash
# main에서 분기 후 변경사항
git diff main...HEAD

# 변경된 파일 목록만
git diff main...HEAD --name-only

# 통계
git diff main...HEAD --stat
```

### 특정 파일 히스토리

```bash
# 파일의 최근 변경
git diff HEAD~1 -- src/app.js

# 두 버전 비교
git diff v1.0.0 v2.0.0 -- src/app.js
```

### 배포 전 확인

```bash
# 스테이징된 변경 최종 확인
git diff --staged

# origin/main과 차이
git diff origin/main..HEAD --stat
```

---

## 관련 문서

- [[Git_MOC|Git MOC로 돌아가기]]
- [[Git_10_태그|이전: 태그]]
- [[Git_12_고급기능|다음: 고급 기능]]

---

*마지막 업데이트: 2026-02-01*
