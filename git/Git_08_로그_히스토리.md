# Git 로그 및 히스토리

#git #git/로그 #git/log #git/history #git/blame

---

## 목차

- [[#Log 기본|Log 기본]]
- [[#Log 포맷|Log 포맷]]
- [[#Log 필터링|Log 필터링]]
- [[#Reflog|Reflog]]
- [[#Show|Show]]
- [[#Blame|Blame]]
- [[#Shortlog|Shortlog]]

---

## Log 기본

| 명령어 | 설명 |
|--------|------|
| `git log` | 커밋 히스토리 |
| `git log --oneline` | 한 줄로 보기 |
| `git log --graph` | 그래프로 보기 |
| `git log --all` | 모든 브랜치 |
| `git log --oneline --graph --all` | 전체 그래프 (추천) |
| `git log -p` | 변경 내용(diff) 포함 |
| `git log --stat` | 변경 통계 |
| `git log --name-only` | 변경된 파일명만 |
| `git log --name-status` | 파일명 + 상태 |
| `git log -n 5` | 최근 5개만 |

---

## Log 포맷

| 명령어 | 설명 |
|--------|------|
| `git log --pretty=oneline` | 한 줄 포맷 |
| `git log --pretty=short` | 짧은 포맷 |
| `git log --pretty=full` | 전체 포맷 |
| `git log --pretty=fuller` | 더 자세한 포맷 |
| `git log --pretty=format:"..."` | 커스텀 포맷 |

### 커스텀 포맷 옵션

| 옵션 | 설명 |
|------|------|
| `%H` | 커밋 해시 (전체) |
| `%h` | 커밋 해시 (축약) |
| `%an` | 작성자 이름 |
| `%ae` | 작성자 이메일 |
| `%ad` | 작성 날짜 |
| `%ar` | 작성 날짜 (상대) |
| `%cn` | 커미터 이름 |
| `%s` | 커밋 메시지 제목 |
| `%b` | 커밋 메시지 본문 |

> [!example] 커스텀 포맷 예시
> ```bash
> git log --pretty=format:"%h %an %ar - %s"
> # abc1234 홍길동 2 hours ago - 버그 수정
>
> git log --pretty=format:"%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %s"
> # 색상 적용
> ```

---

## Log 필터링

### 시간/날짜

| 명령어 | 설명 |
|--------|------|
| `git log --since="2024-01-01"` | 특정 날짜 이후 |
| `git log --until="2024-12-31"` | 특정 날짜 이전 |
| `git log --since="2 weeks ago"` | 2주 전부터 |
| `git log --after="yesterday"` | 어제 이후 |

### 작성자/내용

| 명령어 | 설명 |
|--------|------|
| `git log --author="이름"` | 특정 작성자 |
| `git log --author="이름1\|이름2"` | 여러 작성자 |
| `git log --grep="키워드"` | 메시지 검색 |
| `git log --grep="fix" --grep="bug"` | AND 검색 |
| `git log --all-match --grep="fix" --grep="bug"` | 둘 다 포함 |

### 파일/코드

| 명령어 | 설명 |
|--------|------|
| `git log -- <파일>` | 특정 파일 히스토리 |
| `git log -- <폴더>/` | 특정 폴더 히스토리 |
| `git log -S "코드"` | 코드 추가/삭제 검색 |
| `git log -G "정규식"` | 정규식으로 코드 검색 |
| `git log --follow <파일>` | 파일 이름 변경 추적 |

### 브랜치/범위

| 명령어 | 설명 |
|--------|------|
| `git log main..feature` | main에 없는 feature 커밋 |
| `git log feature..main` | feature에 없는 main 커밋 |
| `git log main...feature` | 양쪽에 없는 커밋 |
| `git log --first-parent` | 첫 번째 부모만 |
| `git log --merges` | 머지 커밋만 |
| `git log --no-merges` | 머지 커밋 제외 |

---

## Reflog

HEAD 변경 이력 (복구에 유용)

| 명령어 | 설명 |
|--------|------|
| `git reflog` | HEAD 변경 이력 |
| `git reflog show <브랜치>` | 특정 브랜치 이력 |
| `git reflog -n 10` | 최근 10개만 |
| `git reflog expire --expire=90.days.ago --all` | 90일 이전 삭제 |

> [!tip] Reflog로 복구하기
> 실수로 삭제한 커밋을 복구할 수 있습니다.
> ```bash
> git reflog
> # abc1234 HEAD@{2}: commit: 중요한 작업
>
> git reset --hard abc1234  # 복구
> ```

---

## Show

| 명령어 | 설명 |
|--------|------|
| `git show` | 마지막 커밋 상세 |
| `git show <커밋>` | 특정 커밋 상세 |
| `git show <커밋>:<파일>` | 특정 커밋의 파일 내용 |
| `git show --stat <커밋>` | 변경 통계만 |
| `git show --name-only <커밋>` | 파일명만 |
| `git show <태그>` | 태그 정보 |

---

## Blame

라인별 작성자 확인

| 명령어 | 설명 |
|--------|------|
| `git blame <파일>` | 전체 파일 blame |
| `git blame -L 10,20 <파일>` | 10-20번 라인만 |
| `git blame -L 10,+5 <파일>` | 10번부터 5줄 |
| `git blame -e <파일>` | 이메일 표시 |
| `git blame -w <파일>` | 공백 변경 무시 |
| `git blame -M <파일>` | 파일 내 이동 감지 |
| `git blame -C <파일>` | 파일 간 복사 감지 |
| `git blame --since="2024-01-01" <파일>` | 날짜 이후만 |

---

## Shortlog

커밋 통계/요약

| 명령어 | 설명 |
|--------|------|
| `git shortlog` | 작성자별 커밋 목록 |
| `git shortlog -sn` | 작성자별 커밋 수 (정렬) |
| `git shortlog -sne` | 이메일 포함 |
| `git shortlog --since="2024-01-01"` | 기간 지정 |

---

## 관련 문서

- [[Git_MOC|Git MOC로 돌아가기]]
- [[Git_07_되돌리기|이전: 되돌리기]]
- [[Git_09_Stash|다음: Stash]]

---

*마지막 업데이트: 2026-02-01*
