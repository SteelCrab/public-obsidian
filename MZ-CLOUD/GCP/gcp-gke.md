# Google Kubernetes Engine (GKE) & Artifact Registry (GAR)

#gcp #gke #gar #kubernetes #docker

---

## 1. 개요
GCP의 완전 관리형 Kubernetes 서비스인 **GKE**와 Docker 이미지 저장소인 **Artifact Registry (GAR)**를 활용하여 컨테이너화된 애플리케이션을 배포하는 방법을 다룹니다.

- **Artifact Registry (GAR)**: AWS ECR 대응. 컨테이너 이미지 저장소.
- **GKE (Google Kubernetes Engine)**: AWS EKS 대응. Kubernetes 클러스터 관리.

## 2. 아키텍처

```
[Developer]
    |
    | (Docker Push)
    v
[Artifact Registry (GAR)]
    |
    | (Docker Pull)
    v
[Google Cloud Platform]
    [GKE Cluster (pista-cluster)]
        ├── [Node (e2-medium)]
        │   ├── [Pod: Nginx] <--- (Port 80) --- [Load Balancer] <--- [User]
        │   └── [Pod: FastAPI] <--- (Port 8000) --- [Load Balancer] <--- [User]
```

## 3. 구축 절차 (Scripts)

### 3.1 환경 변수 설정 (`gcp-env.sh`)
```bash
export CLUSTER_NAME="pista-cluster"
export REPO_NAME="pista-repo"
export PROJECT_ROOT="$SCRIPT_DIR/../projects"
export IMG_NGINX="pista-nginx"
export IMG_FASTAPI="pista-fastapi"
```

### 3.2 구축 스크립트 (`gcp-gke-setup.sh`)
이 스크립트는 다음 작업을 자동화합니다:
1. **API 활성화**: `artifactregistry.googleapis.com`, `container.googleapis.com`
2. **GAR 저장소 생성**: `gcloud artifacts repositories create ...`
3. **Docker Build & Push**:
   - `projects/nginx` -> `pista-nginx`
   - `projects/fastapi` -> `pista-fastapi`
4. **GKE 클러스터 생성**: Standard 모드, 1 Node.
5. **Kubernetes 배포**: Deployment, Service(LoadBalancer) 생성.

```bash
bash gcp-gke-setup.sh
```

### 3.3 정리 스크립트 (`gcp-gke-cleanup.sh`)
생성된 GKE 클러스터, GAR 저장소, Kubernetes 리소스를 모두 삭제합니다.
```bash
bash gcp-gke-cleanup.sh
```

## 4. 접속 가이드

- **Nginx (Web)**: `http://<EXTERNAL_IP>:80`
- **FastAPI (API)**: `http://<EXTERNAL_IP>:8000`
- **IP 확인**: `kubectl get service`

## 5. 참고 자료
- [[gcp-cli]] - gcloud CLI 사용법
- [[gcp-vpc]] - VPC 네트워크 구성
