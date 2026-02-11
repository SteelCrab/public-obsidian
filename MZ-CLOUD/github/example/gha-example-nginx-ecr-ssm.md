# GitHub Actions Nginx + ECR 배포 예시

#github #actions #nginx #docker #ecr #aws #ssm #deploy #example

---

Nginx Docker 빌드 → ECR 푸시 → EC2 SSM 배포 워크플로우.

## 플레이스홀더

| 변수 | 값 |
|------|-----|
| `<BUILD_PATH>` | ./nginx/html/ |
| `<CONTAINER_NAME>` | nginx-server |
| `<CONTAINER_PORT>` | 80 |
| `<HOST_PORT>` | 80 |

## 시크릿

| 시크릿 | 설명 |
|--------|------|
| `AWS_ACCESS_KEY_ID` | AWS 액세스 키 ID |
| `AWS_SECRET_ACCESS_KEY` | AWS 시크릿 액세스 키 |
| `AWS_REGION` | AWS 리전 (예: ap-northeast-2) |
| `ECR_REPOSITORY` | ECR 리포지토리 이름 |
| `EC2_INSTANCE_ID` | EC2 인스턴스 ID |

## 워크플로우

```yaml
name: nginx-ecr pipeline

on:
  push:
    branches: ["ci/ecr"]
    paths:
      - "nginx/html/**"
  pull_request:
    branches: ["ci/ecr"]
    paths:
      - "nginx/html/**"

permissions:
  contents: read

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

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
          ECR_REPOSITORY: "${{ secrets.ECR_REPOSITORY }}"
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:latest -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG ./nginx/html/
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

      - name: Deploy to EC2 via SSM
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: "${{ secrets.ECR_REPOSITORY }}"
          IMAGE_TAG: ${{ github.sha }}
        run: |
          aws ssm send-command \
            --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
            --document-name "AWS-RunShellScript" \
            --comment "Deploying Nginx from ECR via SSM" \
            --parameters '{
              "commands": [
                "aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | sudo docker login --username AWS --password-stdin '"$ECR_REGISTRY"'",
                "sudo docker pull '"$ECR_REGISTRY"'/'"$ECR_REPOSITORY"':'"$IMAGE_TAG"'",
                "sudo docker stop nginx-server || true",
                "sudo docker rm nginx-server || true",
                "sudo docker run -d --name nginx-server -p 80:80 '"$ECR_REGISTRY"'/'"$ECR_REPOSITORY"':'"$IMAGE_TAG"'",
                "sudo docker image prune -f"
              ]
            }' \
            --region ${{ secrets.AWS_REGION }}
```

## 관련 노트

- [[gha-aws-configure]] - AWS 인증 설정
- [[gha-ecr-login]] - ECR 로그인
- [[gha-docker-build]] - Docker 빌드
- [[gha-deploy-ssm]] - SSM 배포