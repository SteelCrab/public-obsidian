# Git 스테이징 및 커밋

#git #git/스테이징 #git/커밋 #git/add #git/commit

---

## 목차

- [[#스테이징 (add)|스테이징 (add)]]
- [[#커밋 (commit)|커밋 (commit)]]
- [[#상태 확인 (status)|상태 확인 (status)]]
- [[#스테이징 취소|스테이징 취소]]

---

## 스테이징 (add)

| 명령어 | 설명 |
|--------|------|
| `git add <파일>` | 특정 파일 스테이징 |
| `git add <파일1> <파일2>` | 여러 파일 스테이징 |
| `git add .` | 현재 디렉토리 전체 스테이징 |
| `git add -A` | 모든 변경사항 스테이징 |
| `git add -u` | 수정/삭제된 파일만 (새 파일 제외) |
| `git add -p` | 대화형 스테이징 (hunk 단위) |
| `git add -i` | 대화형 모드 |
| `git add *.js` | 패턴으로 스테이징 |
| `git add src/` | 특정 폴더 스테이징 |

> [!tip] `-p` 옵션 활용
> 파일의 일부분만 선택적으로 스테이징할 수 있습니다.
> - `y`: 이 hunk 스테이징
> - `n`: 이 hunk 건너뛰기
> - `s`: hunk를 더 작게 분할
> - `q`: 종료

---

## 커밋 (commit)

| 명령어 | 설명 |
|--------|------|
| `git commit` | 에디터에서 메시지 작성 |
| `git commit -m "메시지"` | 인라인 메시지로 커밋 |
| `git commit -am "메시지"` | add + commit 동시에 (추적 파일만) |
| `git commit --amend` | 마지막 커밋 수정 |
| `git commit --amend -m "새 메시지"` | 메시지만 수정 |
| `git commit --amend --no-edit` | 메시지 유지하고 파일 추가 |
| `git commit --allow-empty -m "메시지"` | 빈 커밋 생성 |
| `git commit -v` | diff 보면서 커밋 |

> [!warning] `--amend` 주의사항
> 이미 push한 커밋을 amend하면 force push가 필요합니다.
> 협업 시 주의하세요.

---

## 상태 확인 (status)

| 명령어 | 설명 |
|--------|------|
| `git status` | 전체 상태 확인 |
| `git status -s` | 간략한 상태 (short) |
| `git status -sb` | 간략한 상태 + 브랜치 정보 |
| `git status --ignored` | 무시된 파일도 표시 |

### 상태 표시 기호 (-s 옵션)

| 기호 | 의미 |
|------|------|
| `M` | 수정됨 (Modified) |
| `A` | 추가됨 (Added) |
| `D` | 삭제됨 (Deleted) |
| `R` | 이름변경 (Renamed) |
| `??` | 추적되지 않음 (Untracked) |
| `!!` | 무시됨 (Ignored) |

---

## 스테이징 취소

| 명령어 | 설명 |
|--------|------|
| `git reset <파일>` | 특정 파일 스테이징 취소 |
| `git reset` | 모든 스테이징 취소 |
| `git restore --staged <파일>` | 스테이징 취소 (신규 명령어) |

---

## 관련 문서

- [[Git_MOC|Git MOC로 돌아가기]]
- [[Git_02_저장소|이전: 저장소 생성 및 복제]]
- [[Git_04_브랜치|다음: 브랜치 관리]]

---

*마지막 업데이트: 2026-02-01*
