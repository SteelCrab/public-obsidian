#!/bin/bash
# GCP GKE 모듈: GAR + GKE + Nginx/FastAPI 삭제
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/gcp-env.sh"

banner "GKE + Artifact Registry 리소스 정리"

# 1. Kubernetes 리소스 삭제
step 1 3 "Kubernetes Service & Deployment 삭제 중..."

delete_k8s_resource() {
    local type=$1
    local name=$2
    if kubectl get $type $name &>/dev/null; then
        kubectl delete $type $name
        echo "  ✓ $type ($name) 삭제 완료"
    else
        echo "  - $type ($name) 이미 없음"
    fi
}

delete_k8s_resource "service" "$IMG_NGINX"
delete_k8s_resource "service" "$IMG_FASTAPI"
delete_k8s_resource "deployment" "$IMG_NGINX"
delete_k8s_resource "deployment" "$IMG_FASTAPI"

# 2. GKE 클러스터 삭제
step 2 3 "GKE 클러스터 삭제 중 (약 5분 소요)..."
if gcloud container clusters describe $CLUSTER_NAME --region=$REGION &>/dev/null; then
    echo "  - 클러스터 삭제 시작... (시간이 걸립니다)"
    gcloud container clusters delete $CLUSTER_NAME --region=$REGION --quiet
    echo "  ✓ GKE 클러스터 삭제 완료"
else
    echo "  - GKE 클러스터 이미 없음"
fi

# 3. Artifact Registry 삭제
step 3 3 "GAR 저장소 삭제 중..."
if gcloud artifacts repositories describe $REPO_NAME --location=$REGION &>/dev/null; then
    gcloud artifacts repositories delete $REPO_NAME --location=$REGION --quiet
    echo "  ✓ GAR 저장소 삭제 완료"
else
    echo "  - GAR 저장소 이미 없음"
fi

done_banner "GKE 리소스 정리 완료"
echo "API 활성화 상태는 유지됩니다."
echo "=========================================="
