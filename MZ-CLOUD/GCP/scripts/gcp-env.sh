#!/bin/bash
# GCP 공통 환경 변수 및 헬퍼 함수
# 모든 스크립트에서 source 하여 사용

# ==================== 프로젝트 설정 ====================
export PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
export REGION="asia-northeast3"
export ZONE="asia-northeast3-a"

# ==================== 네트워크 ====================
export VPC_NAME="pista-vpc"
export PUBLIC_SUBNET="pista-public-subnet"
export PRIVATE_SUBNET="pista-private-subnet"
export ROUTER_NAME="pista-router"
export NAT_NAME="pista-nat"

# ==================== VM 인스턴스 ====================
export PUBLIC_INSTANCE="pista-public-nginx"
export PRIVATE_INSTANCE="pista-private-nginx"

# ==================== Cloud SQL ====================
export SQL_INSTANCE="pista-mysql"
export SQL_TIER="db-n1-standard-1"
export DB_VERSION="MYSQL_8_0"
export DB_NAME="pista-appdb"
export DB_USER="pista-user"
export DB_USER_PASSWORD="<CHANGE_ME_PASSWORD>"
export ROOT_PASSWORD="<CHANGE_ME_ROOT_PASSWORD>"

# ==================== Load Balancer ====================
export TEMPLATE_NAME="pista-web-template"
export MIG_NAME="pista-web-mig"
export HEALTH_CHECK="pista-health-check"
export BACKEND_SERVICE="pista-backend-service"
export URL_MAP="pista-url-map"
export HTTP_PROXY="pista-http-proxy"
export LB_IP_NAME="pista-lb-ip"
export FORWARDING_RULE="pista-http-rule"

# ==================== GCS + LB ====================
export GCS_BUCKET="pista-static-site"
export GCS_BACKEND_BUCKET="pista-static-backend"
export GCS_URL_MAP="pista-static-url-map"
export GCS_HTTP_PROXY="pista-static-http-proxy"
export GCS_LB_IP="pista-static-lb-ip"
export GCS_FORWARDING_RULE="pista-static-http-rule"

# ==================== GKE & Artifact Registry ====================
export CLUSTER_NAME="pista-cluster"
export REPO_NAME="pista-repo"
export PROJECT_ROOT="$SCRIPT_DIR/../projects"

# Docker Image Names
export IMG_NGINX="pista-nginx"
export IMG_FASTAPI="pista-fastapi"


# ==================== 방화벽 규칙 이름 ====================
export FW_SSH="allow-ssh-${VPC_NAME}"
export FW_HTTP="allow-http-${VPC_NAME}"
export FW_INTERNAL="allow-internal-${VPC_NAME}"
export FW_HEALTH="allow-health-check-${VPC_NAME}"

# ==================== 헬퍼 함수 ====================

# 리소스 존재 여부 확인 후 생성
create_if_not_exists() {
    local check_cmd=$1
    local create_cmd=$2
    local label=$3

    if eval "$check_cmd &>/dev/null"; then
        echo "  ✓ $label 이미 존재"
    else
        eval "$create_cmd"
        echo "  ✓ $label 생성 완료"
    fi
}

# 리소스 존재 여부 확인 후 삭제
delete_if_exists() {
    local check_cmd=$1
    local delete_cmd=$2
    local label=$3

    if eval "$check_cmd &>/dev/null"; then
        eval "$delete_cmd"
        echo "  ✓ $label 삭제 완료"
    else
        echo "  - $label 이미 없음"
    fi
}

# 단계 헤더 출력
step() {
    local current=$1
    local total=$2
    local msg=$3
    echo ""
    echo "[$current/$total] $msg"
}

# 스크립트 시작 배너
banner() {
    local title=$1
    echo "=========================================="
    echo "$title"
    echo "Project: $PROJECT_ID"
    echo "Region:  $REGION / Zone: $ZONE"
    echo "=========================================="
}

# 스크립트 완료 배너
done_banner() {
    local title=$1
    echo ""
    echo "=========================================="
    echo "✓ $title"
    echo "=========================================="
}

# ==================== 네트워크 유틸리티 ====================

# 네트워크 존재 확인 (없으면 에러)
check_network() {
    if ! gcloud compute networks describe $VPC_NAME &>/dev/null; then
        echo "❌ Error: VPC ($VPC_NAME) not found."
        echo "👉 Please run 'bash gcp-network-setup.sh' first."
        exit 1
    fi
    echo "✓ Network found: $VPC_NAME"
}

# 스크립트 디렉토리 (source 경로 해결용)
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
