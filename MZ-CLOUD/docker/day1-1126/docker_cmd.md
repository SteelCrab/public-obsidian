# Docker 명령어 정리 (Day 1)

이 문서는 Docker Day 1 실습에서 사용된 주요 명령어들을 정리한 것입니다.

## 1. 이미지 관리 (Image Management)

| 명령어 | 설명 | 예시 |
| :--- | :--- | :--- |
| `docker pull` | 레지스트리(Docker Hub)에서 이미지를 다운로드합니다. | `docker pull ubuntu:24.04` |
| `docker images` | 로컬에 저장된 이미지 목록을 확인합니다. | `docker images` |
| `docker rmi` | 로컬 이미지를 삭제합니다. | `docker rmi ubuntu:24.04` |

## 2. 컨테이너 관리 (Container Management)

| 명령어 | 설명 | 예시 |
| :--- | :--- | :--- |
| `docker run` | 이미지를 기반으로 컨테이너를 생성하고 실행합니다. | `docker run -it -d -p 80:80 --name web2 ubuntu:24.04` |
| `docker ps` | 현재 실행 중인 컨테이너 목록을 확인합니다. | `docker ps` |
| `docker ps -a` | 중지된 컨테이너를 포함한 모든 컨테이너 목록을 확인합니다. | `docker ps -a` |
| `docker stop` | 실행 중인 컨테이너를 중지합니다. | `docker stop web2` |
| `docker start` | 중지된 컨테이너를 다시 시작합니다. | `docker start web2` |
| `docker rm` | 중지된 컨테이너를 삭제합니다. | `docker rm web2` |

### `docker run` 주요 옵션
- `-i`: Interactive 모드 (표준 입력 활성화)
- `-t`: TTY 할당 (터미널 환경 제공)
- `-d`: Detached 모드 (백그라운드 실행)
- `-p`: 포트 포워딩 (호스트 포트:컨테이너 포트)
- `--name`: 컨테이너 이름 지정

## 3. 컨테이너 내부 명령 실행 (Execution)

| 명령어 | 설명 | 예시 |
| :--- | :--- | :--- |
| `docker exec` | 실행 중인 컨테이너 내부에서 명령을 실행합니다. | `docker exec -it web2 /bin/bash` |

### 팁: 단일 명령 실행
컨테이너에 접속하지 않고 바로 명령을 실행하려면 `/bin/bash -c`를 사용합니다.
```bash
docker exec web2 /bin/bash -c "apt update && apt install -y nginx"
```

## 4. 파일 복사 (File Transfer)

| 명령어 | 설명 | 예시 |
| :--- | :--- | :--- |
| `docker cp` | 호스트와 컨테이너 간에 파일을 복사합니다. | `docker cp index.html web2:/var/www/html/index.html` |

## 5. 상태 확인 (Verification)

| 명령어 | 설명 | 예시 |
| :--- | :--- | :--- |
| `curl` | 웹 서버에 요청을 보내 응답을 확인합니다. | `curl -I http://localhost` |
