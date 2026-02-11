# ASG 배포 파이프라인

#cicd #asg #alb #ecr #ssm #aws

---

GitHub Actions → ECR Push → SSM Send-Command → ASG 내 다중 EC2 동시 배포.
Auto Scaling과 Load Balancer를 활용한 프로덕션 수준 배포 방식이다.

---

## 파이프라인 흐름

```
개발자 → git push → GitHub Actions
                       │
                  ┌────┴────┐
                  │   CI    │
                  │ 빌드    │
                  │ ECR Push│
                  └────┬────┘
                       │
                  ┌────┴────┐
                  │   CD    │
                  │ SSM     │
                  │ 태그 기반 │
                  └────┬────┘
                       │
         ┌─────────────┼─────────────┐
         ▼             ▼             ▼
      EC2 (ASG)     EC2 (ASG)     EC2 (ASG)
                       │
                      ALB
                       │
                    사용자
```

---

## 구축 순서

| 단계 | 작업 | 설명 |
|------|------|------|
| 1 | EC2 생성 | SSM Agent + Docker + AWS CLI 설치 |
| 2 | AMI 생성 | 설정 완료된 EC2에서 스냅샷 |
| 3 | Launch Template | AMI + IAM 역할 + 보안그룹 + 태그 |
| 4 | ASG 생성 | Launch Template 기반 자동 확장 그룹 |
| 5 | ALB 생성 | ALB + 대상그룹 + ASG 연결 |
| 6 | GitHub Actions | ECR Push + SSM Send-Command |

---

## EC2 사용자 데이터

```bash
#!/bin/bash

# 1. SSM 에이전트 설치 (최우선)
snap install amazon-ssm-agent --classic
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# 2. 패키지 업데이트
apt-get update -y
apt-get install -y curl unzip net-tools apt-transport-https ca-certificates gnupg lsb-release

# 3. Docker 설치
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
usermod -aG docker ubuntu

# 4. AWS CLI v2 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws/
```

---

## IAM 역할

| 정책 | 용도 |
|------|------|
| `AmazonSSMManagedInstanceCore` | SSM 기본 |
| `AmazonEC2RoleforSSM` | SSM EC2 연동 |
| `AmazonS3ReadOnlyAccess` | S3 읽기 |
| `AmazonEC2ContainerRegistryReadOnly` | ECR 이미지 풀 |

---

## Launch Template 설정

| 항목 | 설명 |
|------|------|
| AMI | SSM + Docker 설치 완료된 AMI |
| 인스턴스 타입 | t3.micro 이상 |
| IAM 역할 | SSM + ECR 권한 |
| 보안 그룹 | HTTP(80) + 커스텀 포트 (아래 참조) |
| 태그 | `Name: <ASG_TAG_VALUE>` (SSM 배포 대상 식별) |

> [!Important]
> 태그는 SSM Send-Command의 대상 식별에 사용되므로 반드시 설정해야 한다.

### 보안 그룹 규칙

#### EC2 보안 그룹 (ASG 인스턴스)

| 방향 | 포트 | 프로토콜 | 소스/대상 | 용도 |
|------|------|----------|----------|------|
| Inbound | 80 | TCP | ALB SG | HTTP (ALB에서 전달) |
| Inbound | 443 | TCP | `0.0.0.0/0` | HTTPS (필요 시) |
| Outbound | All | All | `0.0.0.0/0` | ECR Pull, SSM 통신 |

#### ALB 보안 그룹

| 방향 | 포트 | 프로토콜 | 소스/대상 | 용도 |
|------|------|----------|----------|------|
| Inbound | 80 | TCP | `0.0.0.0/0` | HTTP 트래픽 |
| Inbound | 443 | TCP | `0.0.0.0/0` | HTTPS 트래픽 |
| Outbound | 80 | TCP | EC2 SG | 대상 그룹으로 전달 |

> [!Note]
> SSM 방식은 SSH 22번 포트가 **불필요**하다.
> ALB → EC2 트래픽은 **보안 그룹 간 참조**로 제한하는 것이 안전하다.

---

## GitHub Secrets

### ASG + SSM 배포 (`nginx-asg-s3.yaml`)

| 시크릿 | 설명 | 예시 |
|--------|------|------|
| `AWS_ACCESS_KEY_ID` | IAM 액세스 키 | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | IAM 시크릿 키 | |
| `AWS_REGION` | AWS 리전 | `ap-northeast-2` |
| `ECR_REPOSITORY` | ECR 레포지토리 이름 | `pista-nginx` |
| `ASG_TAG_KEY` | EC2 태그 키 | `Name` |
| `ASG_TAG_VALUE` | EC2 태그 값 | ASG에서 자동 생성된 인스턴스 태그 |

> [!Note]
> ASG 방식은 `EC2_INSTANCE_ID` 대신 `ASG_TAG_KEY` + `ASG_TAG_VALUE`를 사용한다.
> SSM Send-Command가 태그로 대상을 식별하여 모든 ASG 인스턴스에 동시 배포한다.

---

## SSM Send-Command (핵심)

```bash
aws ssm send-command \
  --targets "Key=tag:$ASG_TAG_KEY,Values=$ASG_TAG_VALUE" \
  --document-name "AWS-RunShellScript" \
  --parameters '{
    "commands": [
      "aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY",
      "docker pull $FULL_IMAGE",
      "docker stop app || true",
      "docker rm app || true",
      "docker run -d --name app -p 80:80 $FULL_IMAGE",
      "docker image prune -f"
    ]
  }'
```

> [!Note]
> `--targets`에 태그를 지정하면 ASG 내 모든 EC2에 동시에 명령이 전달된다.

---

## 주의사항

> [!Important]
> - SSM 에이전트가 모든 EC2에서 활성화된 후 CD 배포를 실행해야 한다
> - EC2가 새로 생성되면 수동으로 CD를 다시 실행해야 한다
> - Systems Manager > 플릿 관리자에서 에이전트 상태를 확인할 것

---

## SSM 단일 vs ASG 배포 비교

| 항목 | SSM 단일 배포 | ASG 배포 |
|------|-------------|---------|
| 대상 | 단일 EC2 | 다중 EC2 (자동확장) |
| 스케일링 | 수동 | ASG 자동 |
| 로드밸런서 | 없음 | ALB |
| 배포 방식 | instance-id 지정 | 태그 기반 동시 배포 |

---

## 장단점

| 항목 | 내용 |
|------|------|
| 장점 | 다중 인스턴스 동시 배포, 자동 스케일링, ALB 연동 |
| 단점 | AMI/Launch Template 관리 필요, 새 인스턴스 생성 시 재배포 |
| 적합 환경 | 고가용성 필요, 트래픽 변동 있는 서비스 |

---

## 관련 노트

- [[CICD_2026-02-05]] - ASG 배포 실습 일지
- [[cicd-deploy-ssm]] - 이전 단계: SSM 배포
- [[cicd-deploy-eks]] - 다음 단계: EKS 배포
- [[aws-asg]] - Auto Scaling Group
- [[aws-iam]] - IAM 역할
