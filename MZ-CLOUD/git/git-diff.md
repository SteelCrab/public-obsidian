# Git Diff

#git #diff #비교

---

변경사항을 비교한다.

## 기본 비교

| 명령어 | 설명 |
|--------|------|
| `git diff` | 작업 디렉토리 변경 |
| `git diff --staged` | 스테이징된 변경 |
| `git diff HEAD` | 모든 변경 (staged + unstaged) |
| `git diff -- <파일>` | 특정 파일만 |

## 커밋/브랜치 비교

| 명령어 | 설명 |
|--------|------|
| `git diff <커밋1> <커밋2>` | 두 커밋 비교 |
| `git diff HEAD~3..HEAD` | 최근 3개 커밋 변경 |
| `git diff main..feature` | 두 브랜치 비교 |
| `git diff main...feature` | 분기 후 feature 변경 |

## 출력 옵션

| 옵션 | 설명 |
|------|------|
| `--stat` | 변경 통계 |
| `--name-only` | 파일명만 |
| `--color-words` | 단어 단위 비교 |
| `-w` | 공백 무시 |

> [!info] .. vs ...
> `main..feature`: 직접 비교
> `main...feature`: 분기점 이후 변경만 (PR 리뷰에 유용)
