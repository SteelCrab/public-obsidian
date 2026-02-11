# Docker 컨테이너 실행

#docker #run #컨테이너

---

컨테이너 실행 옵션.

| 명령어 | 설명 |
|--------|------|
| `docker run <이미지>` | 컨테이너 실행 |
| `docker run -d <이미지>` | 백그라운드 실행 |
| `docker run -it <이미지> /bin/bash` | 대화형 실행 |
| `docker run -p 8080:80 <이미지>` | 포트 매핑 |
| `docker run -v /host:/container <이미지>` | 볼륨 마운트 |
| `docker run --name <이름> <이미지>` | 컨테이너 이름 지정 |
| `docker run --rm <이미지>` | 종료 시 자동 삭제 |
| `docker run -e KEY=VALUE <이미지>` | 환경변수 설정 |

