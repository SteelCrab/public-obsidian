# Git Log 포맷

#git #log #format

---

로그 출력 형식을 커스터마이즈한다.

| 명령어 | 설명 |
|--------|------|
| `git log --pretty=oneline` | 한 줄 |
| `git log --pretty=short` | 짧게 |
| `git log --pretty=full` | 전체 |
| `git log --pretty=format:"..."` | 커스텀 |

## 포맷 옵션

| 옵션 | 설명 |
|------|------|
| `%H` | 커밋 해시 (전체) |
| `%h` | 커밋 해시 (축약) |
| `%an` | 작성자 이름 |
| `%ae` | 작성자 이메일 |
| `%ad` | 작성 날짜 |
| `%ar` | 작성 날짜 (상대) |
| `%s` | 커밋 메시지 제목 |

## 예시

```bash
# 기본 포맷
git log --pretty=format:"%h %an %ar - %s"
# abc1234 홍길동 2 hours ago - 버그 수정

# 색상 포맷
git log --pretty=format:"%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %s"
```

> [!tip] alias로 등록
> 자주 쓰는 포맷은 [[git-config-alias]]로 등록하자.

---

## 연결 노트

- [[git-log]] - 로그 기본
- [[git-config-alias]] - 별칭 설정
- [[Git_MOC]]
