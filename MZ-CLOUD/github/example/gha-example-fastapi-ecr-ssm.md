# GitHub Actions FastAPI + ECR 배포 예시

#github #actions #python #fastapi #docker #ecr #aws #ssm #deploy #example

---

Python 테스트 → Docker 빌드 → ECR 푸시 → EC2 SSM 배포 워크플로우.

## 플레이스홀더

| 변수 | 값 |
|------|-----|
| `<PYTHON_VERSION>` | 3.14 |
| `<BUILD_PATH>` | ./fastapi/ |
| `<CONTAINER_NAME>` | fastapi-server |
| `<CONTAINER_PORT>` | 8000 |
| `<HOST_PORT>` | 8000 |

## 시크릿

| 시크릿 | 설명 |
|--------|------|
| `AWS_ACCESS_KEY_ID` | AWS 액세스 키 ID |
| `AWS_SECRET_ACCESS_KEY` | AWS 시크릿 액세스 키 |
| `AWS_REGION` | AWS 리전 (예: ap-northeast-2) |
| `ECR_REPOSITORY_PISTA_FASTAPI` | ECR 리포지토리 이름 |
| `EC2_INSTANCE_ID` | EC2 인스턴스 ID |

## 워크플로우

```yaml
name: fastapi pipeline

on:
  push:
    branches: ["ci/ecr"]
    paths:
      - "fastapi/**"
  pull_request:
    branches: ["ci/ecr"]
    paths:
      - "fastapi/**"

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python 3.14
        uses: actions/setup-python@v3
        with:
          python-version: "3.14"

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install flake8 pytest
          if [ -f fastapi/requirements.txt ]; then pip install -r fastapi/requirements.txt; fi

      - name: Lint with flake8
        run: |
          flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
          flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

      - name: Test with pytest
        run: |
          cd fastapi && pytest

  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: "${{ secrets.AWS_ACCESS_KEY_ID }}"
          aws-secret-access-key: "${{ secrets.AWS_SECRET_ACCESS_KEY }}"
          aws-region: "${{ secrets.AWS_REGION }}"

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push Docker image to ECR
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: "${{ secrets.ECR_REPOSITORY_PISTA_FASTAPI }}"
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:latest -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG ./fastapi/
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

      - name: Deploy to EC2 via SSM
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: "${{ secrets.ECR_REPOSITORY_PISTA_FASTAPI }}"
          IMAGE_TAG: ${{ github.sha }}
        run: |
          aws ssm send-command \
            --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
            --document-name "AWS-RunShellScript" \
            --comment "Deploying FastAPI from ECR via SSM" \
            --parameters '{
              "commands": [
                "aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | sudo docker login --username AWS --password-stdin '"$ECR_REGISTRY"'",
                "sudo docker pull '"$ECR_REGISTRY"'/'"$ECR_REPOSITORY"':'"$IMAGE_TAG"'",
                "sudo docker stop fastapi-server || true",
                "sudo docker rm fastapi-server || true",
                "sudo docker run -d --name fastapi-server -p 8000:8000 '"$ECR_REGISTRY"'/'"$ECR_REPOSITORY"':'"$IMAGE_TAG"'",
                "sudo docker image prune -f"
              ]
            }' \
            --region ${{ secrets.AWS_REGION }}
```

## 관련 노트

- [[gha-setup-python]] - Python 설정
- [[gha-aws-configure]] - AWS 인증 설정
- [[gha-ecr-login]] - ECR 로그인
- [[gha-docker-build]] - Docker 빌드
- [[gha-deploy-ssm]] - SSM 배포