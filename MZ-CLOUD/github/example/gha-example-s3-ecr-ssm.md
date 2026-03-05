# GitHub Actions Nginx + S3 + ECR + SSM 배포 예시

#github #actions #nginx #docker #s3 #ecr #ssm #aws #deploy #example

---

S3 자산 업로드 → Docker 빌드 → ECR 푸시 → EC2 SSM 배포 워크플로우.

정적 파일(HTML, 설정)은 S3에 저장하고, Docker 이미지는 ECR에 푸시한 후 EC2에서 볼륨 마운트로 실행.

## 플레이스홀더

| 변수 | 값 |
|------|-----|
| `<CONFIG_PATH>` | ./default.conf |
| `<HTML_PATH>` | ./html/ |
| `<EC2_APP_PATH>` | /home/ubuntu/app |
| `<CONTAINER_NAME>` | nginx-server |
| `<CONTAINER_PORT>` | 80 |
| `<HOST_PORT>` | 80 |

## 시크릿

| 시크릿                     | 설명                         |
| ----------------------- | -------------------------- |
| `AWS_ACCESS_KEY_ID`     | AWS 액세스 키 ID               |
| `AWS_SECRET_ACCESS_KEY` | AWS 시크릿 액세스 키              |
| `AWS_REGION`            | AWS 리전 (예: ap-northeast-2) |
| `S3_BUCKET_NAME`        | S3 버킷 이름                   |
| `ECR_REPOSITORY`        | ECR 리포지토리 이름               |
| `EC2_INSTANCE_ID`       | EC2 인스턴스 ID                |

## 워크플로우

```yaml
# 워크플로우의 이름입니다. GitHub Actions 탭에서 이 이름으로 표시됩니다.
name: Nginx-Deployment-Pipeline

# 트리거 설정: 어떤 이벤트가 발생했을 때 이 파이프라인을 실행할지 결정합니다.
on:
  push:
    branches: ["ci/s3"] # main 브랜치에 코드가 push될 때 실행
    paths:
      - "nginx/**"
  pull_request:
    branches: ["ci/s3"] # main 브랜치로 PR이 생성될 때 실행
    paths:
      - "nginx/**"

# 권한 설정: GitHub Actions 러너가 리포지토리의 코드를 읽을 수 있도록 허용합니다.
permissions:
  contents: read

jobs:
  # 작업의 이름입니다.
  build-and-deploy:
    runs-on: ubuntu-latest # 최신 Ubuntu 환경의 가상 머신에서 실행됩니다.

    steps:
      # 1단계: 리포지토리에 올린 코드를 가상 머신으로 가져옵니다.
      - name: Checkout code
        uses: actions/checkout@v4

      # 2단계: AWS 명령을 실행하기 위해 자격 증명을 설정합니다.
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }} # IAM 사용자 액세스 키
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }} # IAM 사용자 비밀 키
          aws-region: ${{ secrets.AWS_REGION }} # 대상 AWS 리전 (예: ap-northeast-2)

      # 3단계: 자주 바뀌는 설정 파일과 HTML 정적 자산을 S3 버킷에 업로드합니다.
      - name: Upload Config and Assets to S3
        run: |
          # default.conf 파일을 S3의 config 폴더로 복사합니다.
          aws s3 cp ./nginx/html/default.conf s3://${{ secrets.S3_BUCKET_NAME }}/config/default.conf
          # html 폴더 전체를 S3의 html 폴더와 동기화합니다. (--delete는 로컬에 없는 파일은 S3에서도 삭제)
          aws s3 sync ./nginx/html/ s3://${{ secrets.S3_BUCKET_NAME }}/html/ --delete

      # 4단계: Docker 이미지를 저장할 ECR 리포지토리에 로그인합니다.
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      # 5단계: Docker 이미지를 빌드하고 ECR에 업로드(Push)합니다.
      - name: Build and push Docker image to ECR
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }} # 로그인 단계에서 얻은 레지스트리 주소
          ECR_REPOSITORY: ${{ secrets.ECR_REPOSITORY }} # ECR 리포지토리 이름
          IMAGE_TAG: ${{ github.sha }} # 현재 커밋의 고유 ID(해시값)를 태그로 사용
        run: |
          # Dockerfile을 기반으로 이미지를 빌드합니다. (태그는 고유ID와 latest 두 개 생성)
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG -t $ECR_REGISTRY/$ECR_REPOSITORY:latest ./nginx/html
          # 빌드된 이미지들을 AWS ECR로 전송합니다.
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest

      # 6단계: AWS SSM을 통해 EC2 인스턴스에 접속하여 실제 배포 명령을 내립니다.
      - name: Deploy to EC2 via SSM
        run: |
          # 1. 쉘 스크립트에서 사용할 변수를 정리합니다.
          REGISTRY="${{ steps.login-ecr.outputs.registry }}"
          REPO="${{ secrets.ECR_REPOSITORY }}"
          TAG="${{ github.sha }}"
          FULL_IMAGE="$REGISTRY/$REPO:$TAG"

          # 2. SSM Send-Command를 통해 EC2 내부에서 실행될 명령어를 전달합니다.
          aws ssm send-command \
            --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
            --document-name "AWS-RunShellScript" \
            --comment "Deploying Nginx via GitHub Actions" \
            --region ${{ secrets.AWS_REGION }} \
            --parameters "{
              \"commands\": [
                \"# EC2 내부: html 파일을 담을 디렉토리를 생성합니다.\",
                \"sudo mkdir -p /home/ubuntu/app/html\",

                \"# EC2 내부: S3에 올려둔 최신 설정 파일을 EC2 로컬로 다운로드합니다.\",
                \"aws s3 cp s3://${{ secrets.S3_BUCKET_NAME }}/config/default.conf /home/ubuntu/app/default.conf\",

                \"# EC2 내부: S3의 html 자산들을 EC2 로컬 폴더와 동기화합니다.\",
                \"aws s3 sync s3://${{ secrets.S3_BUCKET_NAME }}/html/ /home/ubuntu/app/html/ --delete\",

                \"# EC2 내부: ECR에서 이미지를 가져오기 위해 Docker 로그인을 수행합니다.\",
                \"aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | sudo docker login --username AWS --password-stdin $REGISTRY\",

                \"# EC2 내부: ECR로부터 새로 빌드된 Docker 이미지를 내려받습니다.\",
                \"sudo docker pull $FULL_IMAGE\",

                \"# EC2 내부: 기존에 실행 중이던 Nginx 컨테이너가 있다면 중지하고 삭제합니다. (실패해도 무시)\",
                \"sudo docker stop nginx-server || true\",
                \"sudo docker rm nginx-server || true\",

                \"# EC2 내부: 새 이미지를 컨테이너로 실행합니다. \",
                \"# 이때 -v 옵션으로 EC2에 다운로드한 S3 파일들을 컨테이너 내부와 연결(마운트)합니다.\",
                \"sudo docker run -d --name nginx-server -p 80:80 \
                  -v /home/ubuntu/app/default.conf:/etc/nginx/conf.d/default.conf \
                  -v /home/ubuntu/app/html:/usr/share/nginx/html \
                  $FULL_IMAGE\",

                \"# EC2 내부: 사용하지 않는 오래된 Docker 이미지들을 정리하여 용량을 확보합니다.\",
                \"sudo docker image prune -f\"
              ]
            }"

```

## 관련 노트

- [[gha-aws-configure]] - AWS 인증 설정
- [[gha-s3-sync]] - S3 동기화
- [[gha-ecr-login]] - ECR 로그인
- [[gha-docker-build]] - Docker 빌드
- [[gha-deploy-ssm]] - SSM 배포