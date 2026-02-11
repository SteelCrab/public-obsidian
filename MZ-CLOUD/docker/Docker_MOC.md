# Docker MOC

#docker #MOC #컨테이너

---

Docker 명령어와 개념을 연결하는 허브 노트.

---

## 설치
[[Linux]]


---

## 이미지

- [[docker-images]] - 이미지 관리

---

## 컨테이너

- [[docker-run]] - 컨테이너 실행
- [[docker-ps]] - 컨테이너 관리
- [[docker-exec]] - 컨테이너 접속
- [[docker-logs]] - 로그와 모니터링

---

## 스토리지와 네트워크

- [[docker-volume]] - 볼륨
- [[docker-network]] - 네트워크

---

## 오케스트레이션

- [[docker-compose]] - Docker Compose

---

## 시스템

- [[docker-system]] - 시스템 정리

---

## 빠른 참조

| 상황 | 명령어 |
|------|--------|
| 이미지 받기 | `docker pull nginx` |
| 컨테이너 실행 | `docker run -d -p 80:80 nginx` |
| 컨테이너 접속 | `docker exec -it <컨테이너> /bin/bash` |
| 로그 확인 | `docker logs -f <컨테이너>` |
| 전체 정리 | `docker system prune -a` |

---
## 이미지 레퍼런스 

* [[fastapi]] - python-fastapi 이미지 구성
---
## docker PAT
* [[docker-pat]]
* 
---

## 학습 기록

- [docker-learning-log](./docker-learning-log.md) - Docker 학습 가이드 (day별)

---

## 외부 링크

- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Compose 문서](https://docs.docker.com/compose/)

---

*Zettelkasten 스타일로 구성됨*
