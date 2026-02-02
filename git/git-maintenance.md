# Git 저장소 관리

#git #maintenance #gc

---

저장소 최적화 및 관리 명령어.

## 가비지 컬렉션

| 명령어 | 설명 |
|--------|------|
| `git gc` | 가비지 컬렉션 |
| `git gc --aggressive` | 강력한 최적화 |
| `git prune` | 연결 없는 객체 삭제 |
| `git fsck` | 무결성 검사 |

## 저장소 크기 확인

```bash
git count-objects -vH
# count: 1234
# size: 12.34 MiB
```

## 아카이브

| 명령어 | 설명 |
|--------|------|
| `git archive HEAD -o file.zip` | ZIP 생성 |
| `git archive --format=tar HEAD > file.tar` | TAR 생성 |
| `git archive --prefix=project/ HEAD -o file.zip` | 접두사 포함 |

## 커밋 정보 조회

| 명령어 | 설명 |
|--------|------|
| `git rev-parse HEAD` | 현재 커밋 해시 |
| `git rev-parse --short HEAD` | 축약 해시 |
| `git rev-parse --abbrev-ref HEAD` | 현재 브랜치명 |
| `git describe --tags` | 가장 가까운 태그 기반 설명 |

## 파일 추적

| 명령어 | 설명 |
|--------|------|
| `git ls-files` | 추적 중인 파일 |
| `git ls-files --others` | 추적되지 않는 파일 |
| `git ls-tree HEAD` | 트리 구조 |

---

## 연결 노트

- [[git-reflog]] - HEAD 이력
- [[git-clean]] - untracked 파일 삭제
- [[Git_MOC]]
