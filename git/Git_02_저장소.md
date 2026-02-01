# Git 저장소 생성 및 복제

#git #git/저장소 #git/init #git/clone

---

## 목차

- [[#새 저장소 생성|새 저장소 생성]]
- [[#원격 저장소 복제|원격 저장소 복제]]
- [[#복제 옵션|복제 옵션]]

---

## 새 저장소 생성

| 명령어 | 설명 |
|--------|------|
| `git init` | 현재 디렉토리에 저장소 초기화 |
| `git init <폴더명>` | 새 폴더에 저장소 생성 |
| `git init --bare` | bare 저장소 생성 (서버용) |
| `git init --bare <폴더명>.git` | 서버용 저장소 생성 |

> [!info] bare 저장소란?
> 작업 디렉토리 없이 Git 데이터만 있는 저장소입니다.
> 주로 원격 서버에서 중앙 저장소로 사용됩니다.

---

## 원격 저장소 복제

| 명령어 | 설명 |
|--------|------|
| `git clone <URL>` | 저장소 복제 |
| `git clone <URL> <폴더명>` | 지정 폴더에 복제 |
| `git clone git@github.com:user/repo.git` | SSH로 복제 |
| `git clone https://github.com/user/repo.git` | HTTPS로 복제 |

---

## 복제 옵션

| 명령어 | 설명 |
|--------|------|
| `git clone --depth 1 <URL>` | 최신 커밋만 복제 (shallow) |
| `git clone --depth 10 <URL>` | 최근 10개 커밋만 복제 |
| `git clone --branch <브랜치> <URL>` | 특정 브랜치만 복제 |
| `git clone --single-branch <URL>` | 기본 브랜치만 복제 |
| `git clone --recurse-submodules <URL>` | 서브모듈 포함 복제 |
| `git clone --mirror <URL>` | 완전한 미러 복제 |

> [!tip] shallow clone 활용
> 대용량 저장소에서 빠르게 최신 코드만 받을 때 유용합니다.
> ```bash
> git clone --depth 1 --single-branch https://github.com/user/repo.git
> ```

---

## 관련 문서

- [[Git_MOC|Git MOC로 돌아가기]]
- [[Git_01_초기설정|이전: 초기 설정]]
- [[Git_03_스테이징_커밋|다음: 스테이징 및 커밋]]

---

*마지막 업데이트: 2026-02-01*
