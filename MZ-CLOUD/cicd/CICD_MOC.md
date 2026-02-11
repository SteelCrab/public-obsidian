# CI/CD MOC

#cicd #MOC #자동화

---

CI/CD 개념과 도구를 연결하는 허브 노트.

---

## 개념

- CI (Continuous Integration) - 지속적 통합
- CD (Continuous Delivery/Deployment) - 지속적 배포

---

## 배포 방식 레퍼런스

| 방식 | 레퍼런스 | 파이프라인 |
|------|----------|-----------|
| SSH 배포 | [[cicd-deploy-ssh]] | GitHub Actions → DockerHub → SSH → EC2 |
| SSM 배포 | [[cicd-deploy-ssm]] | GitHub Actions → DockerHub/ECR → SSM → EC2 |
| ASG 배포 | [[cicd-deploy-asg]] | GitHub Actions → ECR → SSM → ASG (다중 EC2) |
| EKS 배포 | [[cicd-deploy-eks]] | eksctl → EKS → LB Controller → ALB Ingress |

---

## 배포 방식 비교

| 항목 | SSH 배포 | SSM 배포 | ASG + SSM | EKS |
|------|---------|---------|-----------|-----|
| 배포 대상 | 단일 EC2 | 단일 EC2 | 다중 EC2 (자동확장) | Pod (컨테이너) |
| 접속 방식 | SSH 키 | AWS SSM | SSM + 태그 | kubectl |
| 이미지 저장소 | DockerHub | DockerHub / ECR | ECR | ECR |
| 로드밸런서 | 없음 | 없음 | ALB (EC2 대상) | ALB (Ingress) |
| 스케일링 | 수동 | 수동 | ASG 자동 | HPA/ReplicaSet |
| 복잡도 | 낮음 | 낮음 | 중간 | 높음 |

---

## 학습 진행 흐름

```
SSH 배포              ← 가장 기본적인 방식
  │
SSM 배포              ← SSH 키 관리 불필요, AWS 네이티브
  │   ├─ DockerHub 방식
  │   └─ ECR 방식     ← AWS 내부 통신, 더 빠르고 안전
  │
ASG + S3 배포          ← 오토 스케일링, 다중 인스턴스 동시 배포
  │
EKS 클러스터 구축       ← 컨테이너 오케스트레이션 진입
  │
EKS FastAPI + Nginx    ← Nginx(NLB) + FastAPI(ClusterIP) + Kustomize + ArgoCD
  │
ALB Ingress 배포       ← 경로 기반 라우팅, 멀티 컨테이너
  │
IRSA                   ← Pod 단위 IAM 역할
```

---

## 학습 일지

| 날짜 | 노트 | 주제 | 레퍼런스 |
|------|------|------|----------|
| 02-03 | [[CICD_2026-02-03]] | GitHub Actions 첫 실습 | [[cicd-deploy-ssh]] |
| 02-04 | [[CICD_2026-02-04]] | DockerHub + SSM 배포 (Nginx, FastAPI) | [[cicd-deploy-ssm]] |
| 02-05 | [[CICD_2026-02-05]] | SSM을 통한 S3 배포 | [[cicd-deploy-asg]] |
| 02-06 | [[CICD_2026-02-06]] | AWS EKS 설치 및 클러스터 구성, LB Controller | [[cicd-deploy-eks]] |
| 02-09 | [[CICD_2026-02-09]] | EKS + Nginx + FastAPI + ArgoCD + Kustomize 배포 | [[cicd-deploy-eks]] |

---

## GitHub Secrets 종합

| 시크릿 | SSH/SSM | ASG | EKS | 설명 |
|--------|:-------:|:---:|:---:|------|
| `AWS_ACCESS_KEY_ID` | O | O | O | IAM 액세스 키 |
| `AWS_SECRET_ACCESS_KEY` | O | O | O | IAM 시크릿 키 |
| `AWS_REGION` | O | O | O | AWS 리전 |
| `DOCKER_USERNAME` | O | - | - | Docker Hub ID |
| `DOCKER_PAT` | O | - | - | Docker Hub 토큰 |
| `EC2_INSTANCE_ID` | O | - | - | SSM 대상 EC2 |
| `ECR_REPOSITORY` | O | O | - | ECR 레포 (범용) |
| `ECR_REPOSITORY_PISTA_FASTAPI` | O | - | - | FastAPI 전용 ECR |
| `ECR_REPOSITORY_FASTAPI_APP` | - | - | O | FastAPI ECR |
| `ECR_REPOSITORY_NGINX_WEB` | - | - | O | Nginx Web ECR |
| `ARGOCD_SERVER` | - | - | O | ArgoCD Server 주소 |
| `ARGOCD_PASSWORD` | - | - | O | ArgoCD admin 비밀번호 |
| `S3_BUCKET_NAME` | O | - | - | S3 버킷 (정적 파일) |
| `ASG_TAG_KEY` | - | O | - | EC2 태그 키 |
| `ASG_TAG_VALUE` | - | O | - | EC2 태그 값 |

> 상세 시크릿은 각 배포 레퍼런스 참고: [[cicd-deploy-ssh]], [[cicd-deploy-ssm]], [[cicd-deploy-asg]], [[cicd-deploy-eks]]

---

## GitHub Actions

- [[GitHub_Actions_MOC]] - GitHub Actions 상세 MOC
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)

---

## 워크플로우 예시

| 워크플로우 | 설명 | 배포 방식 |
|----------|------|----------|
| [[gha-example-fastapi-dockerhub]] | FastAPI → DockerHub → SSH 배포 | SSH |
| [[gha-examplel-nginx-dockerhub]] | Nginx → DockerHub → SSM 배포 | SSM |
| [[gha-example-nginx-ecr-ssm]] | Nginx → ECR → SSM 배포 | SSM |
| [[gha-example-fastapi-ecr-ssm]] | FastAPI → ECR → SSM 배포 | SSM |

---

## AWS 리소스

- [[aws-resource-2026-02-04-1]] - AWS 리소스 Blueprint

---

## 실습 프로젝트

- [cicd-test](https://github.com/SteelCrab/cicd-test) - CI/CD 실습 레포

| 브랜치 | 배포 방식 | 주요 기술 |
|--------|----------|----------|
| `main` | SSH / SSM | FastAPI + Nginx + DockerHub |
| `ci/s3` | SSM + S3 | Nginx + ECR + S3 정적 파일 |
| `ci/asg` | ASG + SSM | ECR + SSM 태그 기반 다중 배포 |
| `ci/eks-fastapi` | EKS + ArgoCD | Nginx + FastAPI + ECR + NLB + ArgoCD |
| `ci/eks-rust` | EKS + Kustomize | Nginx + Rust API + IRSA + NLB |

---

## 관련 노트

- [[git-push]] - 원격 저장소에 푸시하여 워크플로우 트리거
- [[git-remote]] - 원격 저장소 설정
- [[aws-ec2]] - EC2 인스턴스 설정
- [[aws-iam]] - IAM 역할 설정
- [[aws-asg]] - Auto Scaling Group
- [[k8s-service]] - Kubernetes Service 개요
- [[k8s-service-clusterip]] - ClusterIP
- [[k8s-service-nodeport]] - NodePort

---

## 외부 링크

- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [AWS EKS 공식 문서](https://docs.aws.amazon.com/eks/)

---

*Zettelkasten 스타일로 구성됨*
