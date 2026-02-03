# Git 저장소 초기화

#git #init #저장소

---

새로운 Git 저장소를 생성한다.

| 명령어 | 설명 |
|--------|------|
| `git init` | 현재 디렉토리에 저장소 생성 |
| `git init <폴더명>` | 새 폴더에 저장소 생성 |
| `git init --bare` | bare 저장소 생성 |
| `git init --bare <폴더명>.git` | 서버용 저장소 생성 |

## bare 저장소

작업 디렉토리 없이 Git 데이터만 있는 저장소.
주로 원격 서버에서 중앙 저장소로 사용된다.

```bash
# 서버에 중앙 저장소 생성
git init --bare /srv/git/project.git
```

---

## 연결 노트

- [[git-clone]] - 저장소 복제
- [[git-remote]] - 원격 저장소 연결
- [[Git_MOC]]
