# EKS 배포 파이프라인

#cicd #eks #kubernetes #alb #ingress #aws

---

eksctl → EKS 클러스터 → AWS LB Controller → Deployment + Service + Ingress 배포.
컨테이너 오케스트레이션 기반의 프로덕션 배포 방식이다.

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
                  │ kubectl │
                  │ apply   │
                  └────┬────┘
                       │
           ┌───────────┼───────────┐
           ▼           ▼           ▼
         Pod         Pod         Pod
           └───────────┼───────────┘
                   Service
                       │
                   Ingress (ALB)
                       │
                    사용자
```

---

## 1. 도구 설치

| 도구 | 용도 | Mac 설치 |
|------|------|----------|
| kubectl | K8s 클러스터 제어 | `brew install kubectl` |
| AWS CLI | AWS 서비스 제어 | `brew install awscli` |
| eksctl | EKS 클러스터 관리 | `brew install weaveworks/tap/eksctl` |
| Helm | K8s 패키지 관리 | `brew install helm` |

```shell
# Helm EKS 차트 저장소 추가
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```

---

## 2. 서브넷 태그 설정 (필수)

| 태그 키 | 값 | 대상 | 설명 |
|---------|-----|------|------|
| `kubernetes.io/role/elb` | `1` | 퍼블릭 서브넷 | 외부 LB용 |
| `kubernetes.io/role/internal-elb` | `1` | 프라이빗 서브넷 | 내부 LB용 |
| `kubernetes.io/cluster/<NAME>` | `shared` | 모든 서브넷 | 클러스터 리소스 |

```bash
# 퍼블릭 서브넷 태그
aws ec2 create-tags --resources <PUBLIC_SUBNETS> \
  --tags Key=kubernetes.io/role/elb,Value=1

# 프라이빗 서브넷 태그
aws ec2 create-tags --resources <PRIVATE_SUBNETS> \
  --tags Key=kubernetes.io/role/internal-elb,Value=1
```

---

## 3. 보안 그룹 설정

### 보안 그룹 구성도

```
인터넷
  │
  ▼
┌─────────────────────────────┐
│  LB 보안 그룹 (<LB_SG_ID>)   │  ← 외부 트래픽 수신
│  Inbound: 80, 443 (0.0.0.0/0)│
│  Outbound: All              │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│  노드 보안 그룹 (<NODE_SG_ID>) │  ← 워커 노드
│  Inbound: LB SG, 클러스터 SG  │
│  Outbound: All              │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│  클러스터 보안 그룹 (자동 생성)   │  ← EKS 컨트롤 플레인
│  Inbound: 노드 SG (443)     │
│  Outbound: 노드 SG (All)    │
└─────────────────────────────┘
```

### 보안 그룹별 규칙

#### LB 보안 그룹 (NLB/ALB용)

| 방향 | 포트 | 프로토콜 | 소스/대상 | 설명 |
|------|------|----------|----------|------|
| Inbound | 80 | TCP | `0.0.0.0/0` | HTTP 트래픽 |
| Inbound | 443 | TCP | `0.0.0.0/0` | HTTPS 트래픽 |
| Outbound | All | All | `0.0.0.0/0` | 모든 아웃바운드 |

#### 노드 보안 그룹 (워커 노드)

| 방향 | 포트 | 프로토콜 | 소스/대상 | 설명 |
|------|------|----------|----------|------|
| Inbound | All | All | 노드 SG (자기 자신) | 노드 간 통신 |
| Inbound | All | All | 클러스터 SG | 컨트롤 플레인 → 노드 |
| Inbound | 80 | TCP | LB SG | LB → Nginx Pod |
| Inbound | 8080 | TCP | LB SG | LB → API Pod (NLB instance 타입 시) |
| Inbound | 30000-32767 | TCP | LB SG | NodePort 범위 (instance 타입 시) |
| Outbound | All | All | `0.0.0.0/0` | ECR Pull, 외부 API 등 |

#### 클러스터 보안 그룹 (EKS 자동 생성)

| 방향 | 포트 | 프로토콜 | 소스/대상 | 설명 |
|------|------|----------|----------|------|
| Inbound | 443 | TCP | 노드 SG | kubelet → API 서버 |
| Outbound | All | All | 노드 SG | API 서버 → kubelet |

> [!Important]
> - 클러스터 보안 그룹은 `eksctl create cluster` 시 **자동 생성**된다
> - LB 보안 그룹은 **수동 생성** 후 Service/Ingress annotation에 지정한다
> - 노드 보안 그룹은 cluster.yaml의 `securityGroups.attachIDs`에 지정한다

### target-type별 필요 포트

| target-type | LB → 노드 필요 포트 | 설명 |
|-------------|-------------------|------|
| `ip` | Pod 포트 직접 (80, 8080) | ALB가 Pod IP로 직접 전달 |
| `instance` | NodePort (30000-32767) | ALB가 노드 경유 |

---

## 4. eksctl 클러스터 설정

### 설정값 테이블

| 플레이스홀더 | 타입 | 설명 |
|-------------|------|------|
| `<CLUSTER_NAME>` | 이름 | EKS 클러스터 이름 |
| `<REGION>` | 이름 | AWS 리전 |
| `<K8S_VERSION>` | 버전 | K8s 버전 (1.29~1.35) |
| `<VPC_ID>` | ID | 기존 VPC ID |
| `<PUBLIC_SUBNET_*>` | ID | 퍼블릭 서브넷 (ALB 배치) |
| `<PRIVATE_SUBNET_*>` | ID | 프라이빗 서브넷 (워커 노드) |
| `<NODE_GROUP_NAME>` | 이름 | 노드 그룹 이름 |
| `<INSTANCE_TYPE>` | 이름 | EC2 타입 (t3.medium 권장) |
| `<DESIRED_CAPACITY>` | 숫자 | 초기 노드 개수 |
| `<NODE_SG_ID>` | ID | 노드 보안 그룹 |
| `<LB_SG_ID>` | ID | LB 보안 그룹 |

### cluster.yaml

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: <CLUSTER_NAME>
  region: <REGION>
  version: "<K8S_VERSION>"

vpc:
  id: "<VPC_ID>"
  subnets:
    public:
      <REGION>a: { id: "<PUBLIC_SUBNET_A>" }
      <REGION>b: { id: "<PUBLIC_SUBNET_B>" }
      <REGION>c: { id: "<PUBLIC_SUBNET_C>" }
    private:
      <REGION>a: { id: "<PRIVATE_SUBNET_A>" }
      <REGION>b: { id: "<PRIVATE_SUBNET_B>" }
      <REGION>c: { id: "<PRIVATE_SUBNET_C>" }
  clusterEndpoints:
    publicAccess: true
    privateAccess: true

managedNodeGroups:
  - name: <NODE_GROUP_NAME>
    instanceType: <INSTANCE_TYPE>
    minSize: 1
    maxSize: 3
    desiredCapacity: <DESIRED_CAPACITY>
    volumeSize: 20
    privateNetworking: true
    securityGroups:
      attachIDs:
        - <NODE_SG_ID>       # 노드 보안 그룹 (워커 노드 트래픽 제어)
    iam:
      withAddonPolicies:
        imageBuilder: true    # ECR 접근
        autoScaler: true      # Cluster Autoscaler
        albIngress: true      # LB 권한
        cloudWatch: true      # 로그
        ebs: true             # EBS 볼륨
        certManager: true     # SSL/TLS 인증서
        externalDNS: true     # Route53 연결

iam:
  withOIDC: true
```

### 관련 명령어

| 명령어 | 설명 |
|--------|------|
| `eksctl create cluster -f cluster.yaml` | 클러스터 생성 |
| `eksctl delete cluster -f cluster.yaml` | 클러스터 삭제 |
| `aws eks update-kubeconfig --region <REGION> --name <NAME>` | kubeconfig 연결 |
| `kubectl get nodes` | 노드 상태 확인 |

> [!Note] OIDC
> Pod에 IAM 역할을 부여하는 IRSA(IAM Roles for Service Accounts) 기능에 필요하다.
> 노드 전체가 아닌 **특정 Pod에만** AWS 권한을 부여할 수 있다.

---

## 5. AWS LB Controller 설치

```bash
# 1. IAM Policy 생성
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json

# 2. ServiceAccount 생성 (IRSA)
eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

# 3. Helm 설치
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# 확인
kubectl get deployment -n kube-system aws-load-balancer-controller
```

---

## 6. 배포 방식 비교

### 방식 A: ClusterIP + ALB (target-type: ip)

```
사용자 → ALB → Pod IP 직접 (1홉)
```

- ALB가 Pod IP로 직접 트래픽 전달
- **VPC CNI 환경 필수**
- 성능 우수

### 방식 B: NodePort + ALB (target-type: instance)

```
사용자 → ALB → Node:NodePort → Pod (2홉)
```

- ALB가 노드의 NodePort를 경유
- VPC CNI 불필요 (호환성 높음)
- 추가 홉으로 약간 느림

### 비교 테이블

| 항목 | ClusterIP + ip | NodePort + instance |
|------|---------------|---------------------|
| Service 타입 | ClusterIP | NodePort |
| ALB target-type | ip | instance |
| VPC CNI 필수 | O | X |
| 네트워크 홉 | 1 | 2 |
| 성능 | 빠름 | 약간 느림 |

---

## 7. 매니페스트 예시

### Deployment (멀티 컨테이너)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-project
  template:
    metadata:
      labels:
        app: web-project
    spec:
      containers:
        - name: nginx
          image: <ECR_REGISTRY>/nginx:latest
          ports:
            - containerPort: 80
          resources:
            requests: { cpu: "100m", memory: "128Mi" }
            limits: { cpu: "250m", memory: "256Mi" }
        - name: fastapi
          image: <ECR_REGISTRY>/fastapi:latest
          ports:
            - containerPort: 8000
          resources:
            requests: { cpu: "100m", memory: "128Mi" }
            limits: { cpu: "500m", memory: "256Mi" }
```

### Service (ClusterIP)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  type: ClusterIP
  selector:
    app: web-project
  ports:
    - name: http
      port: 80
      targetPort: 80
    - name: api
      port: 8000
      targetPort: 8000
```

### Ingress (ALB)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/security-groups: <ALB_SG>
    alb.ingress.kubernetes.io/healthcheck-path: /
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-svc
                port:
                  number: 80
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: web-svc
                port:
                  number: 8000
```

---

## 8. 배포 명령어

```bash
# 배포
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# 확인
kubectl get deploy,svc,ingress

# ALB DNS 테스트
curl http://<ALB_DNS>/
curl http://<ALB_DNS>/api
```

---

## 구현 프로세스 요약

| 단계 | 작업 | 명령어 |
|------|------|--------|
| 1 | VPC 및 서브넷 구축 | AWS 콘솔 |
| 2 | 서브넷 태그 추가 | `aws ec2 create-tags` |
| 3 | 클러스터 생성 | `eksctl create cluster -f cluster.yaml` |
| 4 | kubeconfig 연결 | `aws eks update-kubeconfig` |
| 5 | LB Controller 설치 | IAM → IRSA → Helm |
| 6 | 매니페스트 배포 | `kubectl apply -f` |
| 7 | 접속 테스트 | `curl http://<ALB_DNS>/` |

---

## 장단점

| 항목 | 내용 |
|------|------|
| 장점 | 자동 복구, HPA/ReplicaSet 스케일링, 경로 기반 라우팅, 롤링 업데이트 |
| 단점 | 초기 설정 복잡 (EKS + LB Controller + OIDC), 비용 높음 |
| 적합 환경 | 마이크로서비스, 대규모 프로덕션 |

---

## 실습 프로젝트

- [cicd-test](https://github.com/SteelCrab/cicd-test) - CI/CD 실습 레포 (`ci/eks-rust` 브랜치)

| 브랜치 | 설명 | 배포 방식 |
|--------|------|----------|
| `main` | FastAPI + Nginx → DockerHub → SSH/SSM | [[cicd-deploy-ssh]], [[cicd-deploy-ssm]] |
| `ci/s3` | Nginx → S3 + ECR → SSM | [[cicd-deploy-ssm]] |
| `ci/asg` | Nginx → ECR → SSM → ASG | [[cicd-deploy-asg]] |
| `ci/eks-fastapi` | FastAPI → ECR → EKS (LoadBalancer) | 현재 페이지 |
| `ci/eks-rust` | Nginx + Rust API → ECR → EKS (Kustomize) | 현재 페이지 |

### 주요 디렉토리

| 경로 | 설명 |
|------|------|
| `eks/fastapi/cluster/` | eksctl 클러스터 설정 + LB Controller 설치 스크립트 |
| `eks/fastapi/argocd/` | ArgoCD 설치 + Application 설정 |
| `eks/fastapi/kubernetes/` | K8s 매니페스트 (Kustomize base) |
| `eks/fastapi/overlays/` | 환경별 Kustomize overlay |
| `eks/fastapi/projects/` | 앱 소스 코드 (Nginx, FastAPI) |
| `eks/presignurl/` | Rust API + Nginx (kubectl 방식) |
| `.github/workflows/` | CI/CD 파이프라인 |

---

## GitHub Secrets

### EKS 워크플로우별 시크릿 (ci/eks-fastapi — ArgoCD)

| 시크릿 | FastAPI | Nginx | 설명 |
|--------|:-------:|:-----:|------|
| `AWS_ACCESS_KEY_ID` | O | O | IAM 액세스 키 |
| `AWS_SECRET_ACCESS_KEY` | O | O | IAM 시크릿 키 |
| `AWS_REGION` | O | O | AWS 리전 |
| `ECR_REPOSITORY_FASTAPI_APP` | O | - | FastAPI ECR 레포 |
| `ECR_REPOSITORY_NGINX_WEB` | - | O | Nginx Web ECR 레포 |
| `ARGOCD_SERVER` | O | O | ArgoCD Server 주소 (EXTERNAL-IP) |
| `ARGOCD_PASSWORD` | O | O | ArgoCD admin 비밀번호 |

### EKS 워크플로우별 시크릿 (ci/eks-rust — kubectl)

| 시크릿 | Rust API | Nginx Web | 설명 |
|--------|:--------:|:---------:|------|
| `AWS_ACCESS_KEY_ID` | O | O | IAM 액세스 키 |
| `AWS_SECRET_ACCESS_KEY` | O | O | IAM 시크릿 키 |
| `AWS_REGION` | O | O | AWS 리전 |
| `ECR_REPOSITORY_RUST_API` | O | - | Rust API ECR 레포 |
| `ECR_REPOSITORY_NGINX_WEB` | - | O | Nginx Web ECR 레포 |
| `EKS_CLUSTER_NAME` | O | O | EKS 클러스터 이름 |
| `K8S_NAMESPACE` | O | O | K8s 네임스페이스 |

> [!Note]
> - **ArgoCD 방식** (ci/eks-fastapi): `ARGOCD_SERVER` + `ARGOCD_PASSWORD` 사용, kubeconfig 불필요
> - **kubectl 방식** (ci/eks-rust): `EKS_CLUSTER_NAME` + `K8S_NAMESPACE` 사용
> - 두 워크플로우 모두 `environment: production` 승인 게이트를 사용한다

### 배포 방식별 시크릿 비교

| 시크릿 | SSH/SSM | ASG | EKS (ArgoCD) | EKS (kubectl) |
|--------|:-------:|:---:|:----------:|:------------:|
| `DOCKER_USERNAME` | O | - | - | - |
| `DOCKER_PAT` | O | - | - | - |
| `EC2_INSTANCE_ID` | O | - | - | - |
| `ECR_REPOSITORY` | O | O | - | - |
| `ECR_REPOSITORY_*` | - | - | O | O |
| `ASG_TAG_KEY/VALUE` | - | O | - | - |
| `ARGOCD_SERVER` | - | - | O | - |
| `ARGOCD_PASSWORD` | - | - | O | - |
| `EKS_CLUSTER_NAME` | - | - | - | O |
| `K8S_NAMESPACE` | - | - | - | O |

---

## 관련 노트

- [[CICD_2026-02-06]] - EKS 클러스터 구축 실습
- [[CICD_2026-02-09]] - EKS Nginx + FastAPI + ArgoCD 배포 실습
- [[cicd-deploy-asg]] - 이전 단계: ASG 배포
- [[k8s-service-clusterip]] - ClusterIP Service
- [[k8s-service-nodeport]] - NodePort Service
- [[k8s-service-loadbalancer]] - LoadBalancer Service
- [[Kubectl_MOC]] - kubectl 명령어 MOC
