#!/bin/bash
# GCP GKE 모듈: GAR + GKE + Nginx/FastAPI 배포
# 기존 VPC(pista-vpc) 사용
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/gcp-env.sh"

banner "GKE + Artifact Registry (Nginx & FastAPI) 구축"

# 1. 네트워크 확인
check_network

# 2. API 활성화
step 1 6 "필수 API 활성화 중..."
gcloud services enable artifactregistry.googleapis.com container.googleapis.com --quiet

# 3. Artifact Registry (GAR) 생성
step 2 6 "Docker 이미지 저장소 ($REPO_NAME) 설정 중..."
create_if_not_exists \
    "gcloud artifacts repositories describe $REPO_NAME --location=$REGION" \
    "gcloud artifacts repositories create $REPO_NAME --repository-format=docker --location=$REGION --description='Docker repository for $PROJECT_ID'" \
    "GAR 저장소"

# 4. Docker Build & Push (Nginx & FastAPI)
step 3 6 "Docker 이미지 빌드 및 푸시 중..."

# Docker 인증 설정
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

build_and_push() {
    local service_name=$1
    local image_tag=$2
    local source_dir="$PROJECT_ROOT/$service_name"
    local full_image_url="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${image_tag}:latest"

    echo "  📍 Building $service_name ($source_dir)..."
    if [ ! -d "$source_dir" ]; then
        echo "❌ Error: Source directory not found: $source_dir"
        exit 1
    fi

    docker build -t $full_image_url "$source_dir"
    docker push $full_image_url
    echo "  ✓ $service_name 이미지 푸시 완료: $full_image_url"
}

build_and_push "nginx" "$IMG_NGINX"
build_and_push "fastapi" "$IMG_FASTAPI"

# 5. GKE 클러스터 생성
step 4 6 "GKE 클러스터 생성 중 (약 5분 소요)..."
if ! gcloud container clusters describe $CLUSTER_NAME --region=$REGION &>/dev/null; then
    gcloud container clusters create $CLUSTER_NAME \
        --region=$REGION \
        --num-nodes=1 \
        --machine-type=e2-medium \
        --network=$VPC_NAME \
        --subnetwork=$PUBLIC_SUBNET \
        --disk-size=20GB \
        --enable-ip-alias
    echo "  ✓ GKE 클러스터 생성 완료"
else
    echo "  ✓ GKE 클러스터 이미 존재"
fi

# kubectl 인증 가져오기
gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION

# 6. Kubernetes 배포 (Deployment & Service)
step 5 6 "Kubernetes 애플리케이션 배포 중..."

deploy_app() {
    local app_name=$1
    local image_tag=$2
    local port=$3
    local full_image_url="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${image_tag}:latest"

    # Deployment
    if ! kubectl get deployment $app_name &>/dev/null; then
        kubectl create deployment $app_name --image=$full_image_url --replicas=1
        echo "  ✓ Deployment ($app_name) 생성 완료"
    else
        echo "  - Deployment ($app_name) 이미 존재"
    fi

    # Service (LoadBalancer)
    if ! kubectl get service $app_name &>/dev/null; then
        kubectl expose deployment $app_name --type=LoadBalancer --port=$port --target-port=$port --name=$app_name
        echo "  ✓ Service ($app_name, Port: $port) 생성 완료"
    else
        echo "  - Service ($app_name) 이미 존재"
    fi
}

deploy_app "$IMG_NGINX" "$IMG_NGINX" 80
deploy_app "$IMG_FASTAPI" "$IMG_FASTAPI" 8000

# 7. 접속 정보 출력
step 6 6 "접속 정보 확인"
echo "External IP 할당 대기 중..."
kubectl get service "$IMG_NGINX" "$IMG_FASTAPI"

done_banner "GKE 설정 완료"
echo "Nginx IP:   kubectl get service $IMG_NGINX -w (Port 80)"
echo "FastAPI IP: kubectl get service $IMG_FASTAPI -w (Port 8000)"
echo "정리:       bash gcp-gke-cleanup.sh"
echo "=========================================="
