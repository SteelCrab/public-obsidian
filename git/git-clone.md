# Git 저장소 복제

#git #clone #저장소

---

원격 저장소를 로컬에 복제한다.

| 명령어 | 설명 |
|--------|------|
| `git clone <URL>` | 저장소 복제 |
| `git clone <URL> <폴더명>` | 지정 폴더에 복제 |
| `git clone git@github.com:user/repo.git` | SSH 복제 |
| `git clone https://github.com/user/repo.git` | HTTPS 복제 |

## 복제 옵션

| 옵션 | 설명 |
|------|------|
| `--depth 1` | 최신 커밋만 (shallow clone) |
| `--branch <브랜치>` | 특정 브랜치만 |
| `--single-branch` | 기본 브랜치만 |
| `--recurse-submodules` | 서브모듈 포함 |
| `--mirror` | 완전한 미러 복제 |

## 빠른 복제 예시

```bash
# 대용량 저장소에서 최신 코드만 빠르게
git clone --depth 1 --single-branch https://github.com/user/repo.git
```

---

## 연결 노트

- [[git-init]] - 새 저장소 생성
- [[git-remote]] - 원격 저장소 관리
- [[git-submodule]] - 서브모듈
- [[Git_MOC]]
