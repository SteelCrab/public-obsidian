# GitHub Actions Python + Docker 배포 예시

#github #actions #python #docker #deploy #example

---

Python 테스트 → Docker 빌드 → EC2 배포 워크플로우.

## 플레이스홀더

| 변수 | 값 |
|------|-----|
| `<PYTHON_VERSION>` | 3.12 |
| `<DOCKER_IMAGE>` | fastapi |
| `<CONTAINER_NAME>` | fastapi |
| `<CONTAINER_PORT>` | 8000 |
| `<HOST_PORT>` | 8000 |

## 시크릿

| 시크릿 | 설명 |
|--------|------|
| `DOCKER_USERNAME` | Docker Hub 사용자명 |
| `DOCKER_PAT` | Docker Hub 액세스 토큰 |
| `EC2_HOST` | EC2 퍼블릭 IP |
| `EC2_USERNAME` | ec2-user 또는 ubuntu |
| `SSH_KEY` | EC2 SSH 개인키 |

## 워크플로우

```yaml
name: Python application

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "<PYTHON_VERSION>"

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install flake8 pytest
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

      - name: Lint with flake8
        run: |
          flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
          flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

      - name: Test with pytest
        run: pytest

  deploy:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@v4

      - uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PAT }}

      - uses: docker/setup-buildx-action@v3

      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ secrets.DOCKER_USERNAME }}/<DOCKER_IMAGE>:latest

      - name: Deploy to EC2
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            docker pull ${{ secrets.DOCKER_USERNAME }}/<DOCKER_IMAGE>:latest
            docker stop <CONTAINER_NAME> || true
            docker rm <CONTAINER_NAME> || true
            docker run -d --name <CONTAINER_NAME> -p <HOST_PORT>:<CONTAINER_PORT> ${{ secrets.DOCKER_USERNAME }}/<DOCKER_IMAGE>:latest
```

## 관련 노트

- [[gha-setup-python]] - Python 설정
- [[gha-docker-login]] - Docker 로그인
- [[gha-docker-build]] - Docker 빌드
- [[gha-deploy-ssh]] - SSH 배포
