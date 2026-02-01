# Git 브랜치 관리

#git #git/브랜치 #git/branch #git/checkout #git/switch

---

## 목차

- [[#브랜치 조회|브랜치 조회]]
- [[#브랜치 생성|브랜치 생성]]
- [[#브랜치 전환|브랜치 전환]]
- [[#브랜치 삭제|브랜치 삭제]]
- [[#브랜치 이름 변경|브랜치 이름 변경]]
- [[#브랜치 추적|브랜치 추적]]

---

## 브랜치 조회

| 명령어 | 설명 |
|--------|------|
| `git branch` | 로컬 브랜치 목록 |
| `git branch -r` | 원격 브랜치 목록 |
| `git branch -a` | 모든 브랜치 목록 |
| `git branch -v` | 브랜치별 마지막 커밋 |
| `git branch -vv` | 업스트림 브랜치 정보 포함 |
| `git branch --merged` | 현재 브랜치에 병합된 브랜치 |
| `git branch --no-merged` | 병합되지 않은 브랜치 |
| `git branch --contains <커밋>` | 특정 커밋 포함한 브랜치 |

---

## 브랜치 생성

| 명령어 | 설명 |
|--------|------|
| `git branch <브랜치명>` | 브랜치 생성 (전환 X) |
| `git branch <브랜치명> <커밋>` | 특정 커밋에서 브랜치 생성 |
| `git checkout -b <브랜치명>` | 생성과 동시에 전환 |
| `git switch -c <브랜치명>` | 생성과 동시에 전환 (신규) |
| `git checkout -b <브랜치> <원격>/<브랜치>` | 원격 브랜치 기반 생성 |

---

## 브랜치 전환

| 명령어 | 설명 |
|--------|------|
| `git checkout <브랜치명>` | 브랜치 전환 |
| `git switch <브랜치명>` | 브랜치 전환 (신규 명령어) |
| `git checkout -` | 이전 브랜치로 전환 |
| `git switch -` | 이전 브랜치로 전환 (신규) |

> [!info] checkout vs switch
> `switch`는 Git 2.23에서 추가된 명령어입니다.
> 브랜치 전환 전용으로 더 명확합니다.
> `checkout`은 파일 복원에도 사용되어 혼란스러울 수 있습니다.

---

## 브랜치 삭제

| 명령어 | 설명 |
|--------|------|
| `git branch -d <브랜치명>` | 병합된 브랜치 삭제 |
| `git branch -D <브랜치명>` | 강제 삭제 (병합 여부 무관) |
| `git push origin --delete <브랜치>` | 원격 브랜치 삭제 |
| `git push origin :<브랜치>` | 원격 브랜치 삭제 (축약) |

> [!warning] 강제 삭제 주의
> `-D` 옵션은 병합되지 않은 변경사항도 삭제합니다.
> 데이터 손실에 주의하세요.

---

## 브랜치 이름 변경

| 명령어 | 설명 |
|--------|------|
| `git branch -m <새이름>` | 현재 브랜치 이름 변경 |
| `git branch -m <기존> <새이름>` | 특정 브랜치 이름 변경 |
| `git branch -M <새이름>` | 강제 이름 변경 |

### 원격 브랜치 이름 변경

```bash
# 1. 로컬 브랜치 이름 변경
git branch -m old-name new-name

# 2. 원격의 이전 브랜치 삭제
git push origin --delete old-name

# 3. 새 브랜치 푸시
git push origin -u new-name
```

---

## 브랜치 추적

| 명령어 | 설명 |
|--------|------|
| `git branch -u origin/<브랜치>` | 현재 브랜치 업스트림 설정 |
| `git branch --set-upstream-to=origin/<브랜치>` | 업스트림 설정 (풀네임) |
| `git branch --unset-upstream` | 업스트림 해제 |
| `git checkout --track origin/<브랜치>` | 원격 브랜치 추적 |

---

## 관련 문서

- [[Git_MOC|Git MOC로 돌아가기]]
- [[Git_03_스테이징_커밋|이전: 스테이징 및 커밋]]
- [[Git_05_원격저장소|다음: 원격 저장소]]

---

*마지막 업데이트: 2026-02-01*
