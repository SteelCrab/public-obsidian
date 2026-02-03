# Git Submodule

#git #submodule #고급

---

다른 Git 저장소를 하위 디렉토리로 포함한다.

## 추가/초기화

| 명령어 | 설명 |
|--------|------|
| `git submodule add <URL>` | 서브모듈 추가 |
| `git submodule add <URL> <경로>` | 특정 경로에 추가 |
| `git submodule init` | 초기화 |
| `git submodule update` | 업데이트 |
| `git submodule update --init --recursive` | 재귀적 초기화 |

## 관리

| 명령어 | 설명 |
|--------|------|
| `git submodule status` | 상태 확인 |
| `git submodule foreach <명령>` | 각 서브모듈에서 실행 |
| `git submodule sync` | URL 동기화 |
| `git submodule deinit <경로>` | 등록 해제 |

## 복제 시

```bash
# 서브모듈 포함 복제
git clone --recurse-submodules <URL>

# 이미 복제한 경우
git submodule update --init --recursive
```

> [!warning] 주의사항
> - 서브모듈 변경 후 부모도 커밋 필요
> - 브랜치 전환 시 서브모듈 상태 확인
> - 복잡하면 패키지 매니저 고려

---

## 연결 노트

- [[git-clone]] - 복제
- [[Git_MOC]]
