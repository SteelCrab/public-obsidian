# SSM 배포 파이프라인

#cicd #ssm #docker #ecr #github-actions #aws

---

GitHub Actions → DockerHub/ECR → AWS Systems Manager → EC2 배포.
SSH 키 관리 없이 AWS 네이티브 방식으로 배포한다.

---

## 파이프라인 흐름

```
개발자 → git push → GitHub Actions
                       │
                  ┌────┴────┐
                  │   CI    │
                  │ 빌드    │
                  │ Push    │
                  └────┬────┘
                       │
              DockerHub / ECR
                       │
                  ┌────┴────┐
                  │   CD    │
                  │ SSM     │
                  │ 명령 전달 │
                  └────┬────┘
                       │
                    EC2 배포
```

---

## 방식 비교

| 항목 | DockerHub + SSM | ECR + SSM |
|------|-----------------|-----------|
| 이미지 저장소 | DockerHub | AWS ECR |
| 네트워크 | 외부 통신 | AWS 내부 통신 (더 빠름) |
| 인증 | Docker PAT | IAM 역할 |
| 비용 | 무료 (제한 있음) | ECR 스토리지 비용 |
| 보안 | 토큰 관리 필요 | IAM 기반 (더 안전) |

---

## 필요 리소스

| 리소스 | 설명 |
|--------|------|
| EC2 인스턴스 | SSM Agent + Docker 설치 필수 |
| IAM 역할 | SSM + ECR 권한 |
| 보안 그룹 | HTTP(80) 인바운드 |
| GitHub Secrets | AWS 자격 증명 |

---

## EC2 보안 그룹

| 방향 | 포트 | 프로토콜 | 소스/대상 | 용도 |
|------|------|----------|----------|------|
| Inbound | 80 | TCP | `0.0.0.0/0` | HTTP (웹 서비스) |
| Inbound | 8000 | TCP | `0.0.0.0/0` | FastAPI (직접 접근 시) |
| Outbound | All | All | `0.0.0.0/0` | ECR Pull, SSM 통신 |

> [!Note]
> SSM 방식은 SSH 22번 포트가 **불필요**하다 ([[cicd-deploy-ssh]] 대비 장점).
> SSM Agent는 아웃바운드 HTTPS(443)로 AWS 서비스에 연결한다.

---

## IAM 역할 설정

### 신뢰할 수 있는 엔터티

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["sts:AssumeRole"],
            "Principal": {
                "Service": ["ec2.amazonaws.com"]
            }
        }
    ]
}
```

### 권한 정책

| 방식 | 필요 정책 |
|------|----------|
| SSM 기본 | `AmazonSSMManagedInstanceCore`, `AmazonEC2RoleforSSM` |
| ECR 추가 | `AmazonEC2ContainerRegistryReadOnly`, `AmazonElasticContainerRegistryPublicFullAccess` |

---

## SSM 에이전트 확인

```shell
# Ubuntu
sudo snap services amazon-ssm-agent

# Amazon Linux
sudo systemctl status amazon-ssm-agent
```

> [!Note]
> EC2에 IAM 역할을 부여한 후, AWS 콘솔 > Systems Manager > 플릿 관리자에서 인스턴스가 표시되는지 확인한다.

---

## GitHub Secrets

### 워크플로우별 시크릿

| 시크릿 | DockerHub Nginx | DockerHub FastAPI | ECR Nginx | ECR FastAPI | S3 Nginx |
|--------|:-:|:-:|:-:|:-:|:-:|
| `DOCKER_USERNAME` | O | O | - | - | - |
| `DOCKER_PAT` | O | O | - | - | - |
| `AWS_ACCESS_KEY_ID` | O | O | O | O | O |
| `AWS_SECRET_ACCESS_KEY` | O | O | O | O | O |
| `AWS_REGION` | O | O | O | O | O |
| `EC2_INSTANCE_ID` | O | O | O | O | O |
| `ECR_REPOSITORY` | - | - | O | - | O |
| `ECR_REPOSITORY_PISTA_FASTAPI` | - | - | - | O | - |
| `S3_BUCKET_NAME` | - | - | - | - | O |

> [!Note]
> ECR 방식은 Docker PAT이 불필요하다. IAM 역할로 인증하기 때문이다.
> FastAPI ECR은 전용 레포지토리 시크릿 `ECR_REPOSITORY_PISTA_FASTAPI`를 사용한다.

---

## 워크플로우 구조 (ECR + SSM)

```yaml
name: Deploy via SSM

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # AWS 자격 증명
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      # ECR 로그인
      - id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      # 빌드 + Push
      - name: Build and push
        env:
          REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          REPO: ${{ secrets.ECR_REPOSITORY }}
          TAG: ${{ github.sha }}
        run: |
          docker build -t $REGISTRY/$REPO:$TAG -t $REGISTRY/$REPO:latest .
          docker push $REGISTRY/$REPO:$TAG
          docker push $REGISTRY/$REPO:latest

      # SSM 배포
      - name: Deploy via SSM
        env:
          REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          REPO: ${{ secrets.ECR_REPOSITORY }}
          TAG: ${{ github.sha }}
        run: |
          FULL_IMAGE="$REGISTRY/$REPO:$TAG"
          aws ssm send-command \
            --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
            --document-name "AWS-RunShellScript" \
            --parameters "{
              \"commands\": [
                \"aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | docker login --username AWS --password-stdin $REGISTRY\",
                \"docker pull $FULL_IMAGE\",
                \"docker stop app || true\",
                \"docker rm app || true\",
                \"docker run -d --name app -p 80:80 $FULL_IMAGE\",
                \"docker image prune -f\"
              ]
            }"
```

---

## SSH vs SSM 비교

| 항목 | SSH 배포 | SSM 배포 |
|------|---------|---------|
| 키 관리 | SSH 개인키 필요 | 불필요 (IAM 역할) |
| 보안 | 22번 포트 오픈 | 포트 오픈 불필요 |
| 다중 배포 | 서버별 개별 접속 | 태그 기반 동시 배포 가능 |
| AWS 통합 | 별도 설정 | 네이티브 통합 |

---

## 장단점

| 항목 | 내용 |
|------|------|
| 장점 | SSH 키 불필요, AWS 네이티브, 태그 기반 다중 배포 |
| 단점 | SSM Agent 설치 필요, IAM 설정 복잡 |
| 적합 환경 | AWS 환경, 보안 중시 프로젝트 |

---

## 관련 노트

- [[CICD_2026-02-04]] - SSM 배포 실습 일지
- [[cicd-deploy-ssh]] - 이전 단계: SSH 배포
- [[cicd-deploy-asg]] - 다음 단계: ASG 배포
- [[aws-iam]] - IAM 역할 설정
- [[aws-systemsmanager]] - AWS Systems Manager
