# Git 설정 확인

#git #config #조회

---

현재 설정값을 확인하고 어디서 설정되었는지 추적한다.

| 명령어 | 설명 |
|--------|------|
| `git config --list` | 모든 설정 확인 |
| `git config --global --list` | 전역 설정만 |
| `git config user.name` | 특정 설정값 확인 |
| `git config --show-origin user.name` | 설정 파일 위치 확인 |

## 설정 우선순위

1. 저장소 설정 (`.git/config`)
2. 전역 설정 (`~/.gitconfig`)
3. 시스템 설정 (`/etc/gitconfig`)

---

## 연결 노트

- [[git-config-user]] - 사용자 설정
- [[git-config-alias]] - 별칭 설정
- [[Git_MOC]]
