# Git Log

#git #log #히스토리

---

커밋 히스토리를 조회한다.

| 명령어 | 설명 |
|--------|------|
| `git log` | 커밋 히스토리 |
| `git log --oneline` | 한 줄로 |
| `git log --graph` | 그래프로 |
| `git log --all` | 모든 브랜치 |
| `git log --oneline --graph --all` | 전체 그래프 (추천) |
| `git log -p` | diff 포함 |
| `git log --stat` | 변경 통계 |
| `git log -n 5` | 최근 5개만 |

## 필터링

| 옵션 | 설명 |
|------|------|
| `--since="2024-01-01"` | 날짜 이후 |
| `--author="이름"` | 작성자 |
| `--grep="키워드"` | 메시지 검색 |
| `-- <파일>` | 특정 파일 히스토리 |
| `-S "코드"` | 코드 변경 검색 |
