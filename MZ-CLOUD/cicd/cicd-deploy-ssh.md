# SSH 배포 파이프라인

#cicd #ssh #docker #github-actions #ec2

---

GitHub Actions → DockerHub → SSH → EC2 단일 인스턴스 배포.
가장 기본적인 CI/CD 배포 방식이다.

---

## 파이프라인 흐름

```
개발자 → git push → GitHub Actions
                       │
                  ┌────┴────┐
                  │   CI    │
                  │ 테스트   │
                  │ 빌드    │
                  │ Push    │
                  └────┬────┘
                       │
                  DockerHub
                       │
                  ┌────┴────┐
                  │   CD    │
                  │ SSH 접속 │
                  │ pull+run│
                  └────┬────┘
                       │
                    EC2 배포
```

---

## 필요 리소스

| 리소스 | 설명 |
|--------|------|
| GitHub 리포지토리 | 소스 코드 + 워크플로우 |
| DockerHub 계정 | 이미지 저장소 |
| EC2 인스턴스 | 배포 대상 (Docker 설치 필수) |
| SSH 키 | EC2 접속용 개인키 |

---

## GitHub Secrets

### SSH 방식 (`appleboy/ssh-action`)

| 시크릿 | 설명 |
|--------|------|
| `DOCKER_USERNAME` | Docker Hub ID |
| `DOCKER_PAT` | Docker Hub 토큰 (Read, Write, Delete 권한) |
| `SSH_KEY` | EC2 개인키 (PEM) |
| `EC2_USERNAME` | SSH 접속 사용자 (`ec2-user` / `ubuntu`) |
| `EC2_HOST` | EC2 퍼블릭 IP |

### DockerHub + SSM 방식 (실제 워크플로우)

> [!Note]
> 실습 레포에서는 SSH 대신 SSM을 사용하여 배포한다.

| 시크릿 | 워크플로우 | 설명 |
|--------|-----------|------|
| `DOCKER_USERNAME` | fastapi, nginx | Docker Hub ID |
| `DOCKER_PAT` | fastapi, nginx | Docker Hub 토큰 |
| `AWS_ACCESS_KEY_ID` | fastapi, nginx | IAM 액세스 키 |
| `AWS_SECRET_ACCESS_KEY` | fastapi, nginx | IAM 시크릿 키 |
| `AWS_REGION` | fastapi, nginx | AWS 리전 |
| `EC2_INSTANCE_ID` | fastapi, nginx | SSM 대상 EC2 인스턴스 ID |

---

## 워크플로우 구조

```yaml
name: Deploy via SSH

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      # CI: 테스트
      - uses: actions/checkout@v4
      - name: Run tests
        run: pytest

      # CI: Docker 빌드 + Push
      - name: Docker login
        run: echo "${{ secrets.DOCKER_PAT }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
      - name: Build and push
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/app:latest .
          docker push ${{ secrets.DOCKER_USERNAME }}/app:latest

      # CD: SSH 배포
      - name: Deploy to EC2
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            docker pull ${{ secrets.DOCKER_USERNAME }}/app:latest
            docker stop app || true
            docker rm app || true
            docker run -d --name app -p 80:8000 ${{ secrets.DOCKER_USERNAME }}/app:latest
```

---

## EC2 보안 그룹

| 방향 | 포트 | 프로토콜 | 소스/대상 | 용도 |
|------|------|----------|----------|------|
| Inbound | 22 | TCP | 특정 IP/32 | SSH 접속 |
| Inbound | 80 | TCP | 0.0.0.0/0 | HTTP (웹 서비스) |
| Inbound | 8000 | TCP | 0.0.0.0/0 | FastAPI (직접 접근 시) |
| Outbound | All | All | 0.0.0.0/0 | DockerHub Pull 등 |

> [!Note]
> SSH 방식은 22번 포트를 열어야 하므로 소스를 **특정 IP로 제한**해야 한다.
> SSM 방식으로 전환하면 22번 포트를 닫을 수 있다.

---

## 트러블슈팅

| 문제 | 원인 | 해결 |
|------|------|------|
| Docker Push 실패 | PAT 권한 부족 | Read, Write, Delete 권한 확인 |
| SSH 접속 실패 | 키 권한 또는 사용자명 오류 | `ec2-user` vs `ubuntu` 확인 |
| 포트 접근 불가 | 보안 그룹 미설정 | 인바운드 규칙에 80 포트 추가 |

---

## 장단점

| 항목 | 내용 |
|------|------|
| 장점 | 구현이 간단, 이해하기 쉬움 |
| 단점 | SSH 키 관리 필요, 단일 서버만 배포, 수동 스케일링 |
| 적합 환경 | 학습용, 소규모 프로젝트 |

---

## 관련 노트

- [[CICD_2026-02-03]] - SSH 배포 실습 일지
- [[cicd-deploy-ssm]] - 다음 단계: SSM 배포
- [[gha-example-fastapi-dockerhub]] - 워크플로우 예시
- [[aws-ec2]] - EC2 인스턴스 설정
