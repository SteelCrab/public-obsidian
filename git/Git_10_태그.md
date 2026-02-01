# Git 태그

#git #git/태그 #git/tag #git/버전

---

## 목차

- [[#태그 조회|태그 조회]]
- [[#태그 생성|태그 생성]]
- [[#태그 삭제|태그 삭제]]
- [[#태그 공유|태그 공유]]
- [[#태그 체크아웃|태그 체크아웃]]

---

## 태그 조회

| 명령어 | 설명 |
|--------|------|
| `git tag` | 태그 목록 |
| `git tag -l` | 태그 목록 (동일) |
| `git tag -l "v1.*"` | 패턴으로 검색 |
| `git tag -l "v1.0.*"` | v1.0.x 태그만 |
| `git tag --sort=-version:refname` | 버전순 정렬 |
| `git tag --sort=-creatordate` | 생성일순 정렬 |
| `git show <태그>` | 태그 상세 정보 |
| `git tag --contains <커밋>` | 특정 커밋 포함 태그 |

---

## 태그 생성

### 경량 태그 (Lightweight)

단순히 커밋에 이름만 붙입니다.

| 명령어 | 설명 |
|--------|------|
| `git tag <태그명>` | 현재 커밋에 태그 |
| `git tag <태그명> <커밋>` | 특정 커밋에 태그 |

### 주석 태그 (Annotated)

작성자, 날짜, 메시지 등 메타데이터를 포함합니다.

| 명령어 | 설명 |
|--------|------|
| `git tag -a <태그명>` | 에디터에서 메시지 작성 |
| `git tag -a <태그명> -m "메시지"` | 인라인 메시지 |
| `git tag -a <태그명> <커밋>` | 특정 커밋에 태그 |
| `git tag -a <태그명> <커밋> -m "메시지"` | 특정 커밋 + 메시지 |

### 서명된 태그 (Signed)

GPG 서명을 포함합니다.

| 명령어 | 설명 |
|--------|------|
| `git tag -s <태그명> -m "메시지"` | 서명된 태그 생성 |
| `git tag -v <태그명>` | 서명 검증 |

> [!info] 경량 vs 주석 태그
> - **경량 태그**: 단순 북마크, 임시 표시용
> - **주석 태그**: 릴리스, 버전 관리용 (권장)
>
> 공식 릴리스에는 주석 태그를 사용하세요.

---

## 태그 삭제

| 명령어 | 설명 |
|--------|------|
| `git tag -d <태그명>` | 로컬 태그 삭제 |
| `git push origin --delete <태그명>` | 원격 태그 삭제 |
| `git push origin :refs/tags/<태그명>` | 원격 태그 삭제 (축약) |

### 태그 이름 변경

```bash
# 직접 변경 명령은 없음. 삭제 후 재생성
git tag -d old-tag
git tag new-tag
git push origin --delete old-tag
git push origin new-tag
```

---

## 태그 공유

| 명령어 | 설명 |
|--------|------|
| `git push origin <태그명>` | 특정 태그 푸시 |
| `git push origin --tags` | 모든 태그 푸시 |
| `git push --follow-tags` | 주석 태그만 푸시 |
| `git fetch --tags` | 원격 태그 가져오기 |
| `git pull --tags` | pull + 태그 가져오기 |

> [!tip] --follow-tags 설정
> 커밋 push 시 관련 태그도 자동 push
> ```bash
> git config --global push.followTags true
> ```

---

## 태그 체크아웃

| 명령어 | 설명 |
|--------|------|
| `git checkout <태그명>` | 태그로 체크아웃 (detached HEAD) |
| `git checkout -b <브랜치> <태그명>` | 태그 기반 브랜치 생성 |
| `git switch --detach <태그명>` | 태그로 전환 (신규 명령어) |
| `git switch -c <브랜치> <태그명>` | 태그 기반 브랜치 생성 |

> [!warning] Detached HEAD
> 태그를 직접 체크아웃하면 detached HEAD 상태가 됩니다.
> 변경 작업을 하려면 브랜치를 생성하세요.
> ```bash
> git checkout -b release-fix v1.0.0
> ```

---

## 버전 관리 예시

### Semantic Versioning

```
v1.0.0  - 초기 릴리스
v1.0.1  - 패치 (버그 수정)
v1.1.0  - 마이너 (기능 추가, 하위 호환)
v2.0.0  - 메이저 (Breaking changes)
```

### 릴리스 워크플로우

```bash
# 1. 버전 태그 생성
git tag -a v1.0.0 -m "Release version 1.0.0

Features:
- 로그인 기능
- 회원가입 기능

Bug fixes:
- 홈페이지 로딩 속도 개선"

# 2. 태그 푸시
git push origin v1.0.0

# 3. 또는 모든 태그 푸시
git push --tags
```

### 사전 릴리스 태그

```bash
git tag -a v2.0.0-alpha.1 -m "Alpha release"
git tag -a v2.0.0-beta.1 -m "Beta release"
git tag -a v2.0.0-rc.1 -m "Release candidate"
git tag -a v2.0.0 -m "Stable release"
```

---

## 관련 문서

- [[Git_MOC|Git MOC로 돌아가기]]
- [[Git_09_Stash|이전: Stash]]
- [[Git_11_Diff|다음: 차이점 비교]]

---

*마지막 업데이트: 2026-02-01*
