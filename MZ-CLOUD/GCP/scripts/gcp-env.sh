#!/bin/bash
# GCP 공통 환경 변수 및 헬퍼 함수
# 모든 스크립트에서 source 하여 사용

# ==================== 프로젝트 설정 ====================
export PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
export REGION="asia-northeast1"
export ZONE="asia-northeast1-a"

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

# ==================== Simple VM ====================
export SIMPLE_PUBLIC_VM="pista-pub-nginx"
export SIMPLE_PRIVATE_VM="pista-priv-nginx"

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

# ==================== 공유 네트워크 함수 ====================

# VPC + 서브넷 + Router + NAT + 방화벽을 멱등하게 생성
# 모든 모듈에서 호출하여 네트워크 의존성 자동 해결
ensure_network() {
    echo ""
    echo "--- 네트워크 확인/생성 ---"

    create_if_not_exists \
        "gcloud compute networks describe $VPC_NAME" \
        "gcloud compute networks create $VPC_NAME --subnet-mode=custom --bgp-routing-mode=regional" \
        "VPC ($VPC_NAME)"

    create_if_not_exists \
        "gcloud compute networks subnets describe $PUBLIC_SUBNET --region=$REGION" \
        "gcloud compute networks subnets create $PUBLIC_SUBNET --network=$VPC_NAME --region=$REGION --range=10.0.1.0/24" \
        "Public 서브넷 ($PUBLIC_SUBNET)"

    create_if_not_exists \
        "gcloud compute networks subnets describe $PRIVATE_SUBNET --region=$REGION" \
        "gcloud compute networks subnets create $PRIVATE_SUBNET --network=$VPC_NAME --region=$REGION --range=10.0.2.0/24 --enable-private-ip-google-access" \
        "Private 서브넷 ($PRIVATE_SUBNET)"

    create_if_not_exists \
        "gcloud compute routers describe $ROUTER_NAME --region=$REGION" \
        "gcloud compute routers create $ROUTER_NAME --network=$VPC_NAME --region=$REGION" \
        "Cloud Router ($ROUTER_NAME)"

    create_if_not_exists \
        "gcloud compute routers nats describe $NAT_NAME --router=$ROUTER_NAME --region=$REGION" \
        "gcloud compute routers nats create $NAT_NAME --router=$ROUTER_NAME --region=$REGION --nat-all-subnet-ip-ranges --auto-allocate-nat-external-ips" \
        "Cloud NAT ($NAT_NAME)"

    create_if_not_exists \
        "gcloud compute firewall-rules describe $FW_SSH" \
        "gcloud compute firewall-rules create $FW_SSH --network=$VPC_NAME --allow=tcp:22 --source-ranges=0.0.0.0/0 --description='Allow SSH from anywhere'" \
        "SSH 방화벽 ($FW_SSH)"

    create_if_not_exists \
        "gcloud compute firewall-rules describe $FW_HTTP" \
        "gcloud compute firewall-rules create $FW_HTTP --network=$VPC_NAME --allow=tcp:80,tcp:443 --source-ranges=0.0.0.0/0 --target-tags=http-server" \
        "HTTP 방화벽 ($FW_HTTP)"

    create_if_not_exists \
        "gcloud compute firewall-rules describe $FW_INTERNAL" \
        "gcloud compute firewall-rules create $FW_INTERNAL --network=$VPC_NAME --allow=tcp:0-65535,udp:0-65535,icmp --source-ranges=10.0.0.0/8" \
        "내부 통신 방화벽 ($FW_INTERNAL)"

    create_if_not_exists \
        "gcloud compute firewall-rules describe $FW_HEALTH" \
        "gcloud compute firewall-rules create $FW_HEALTH --network=$VPC_NAME --allow=tcp:80 --source-ranges=130.211.0.0/22,35.191.0.0/16 --target-tags=http-server --description='Allow Google health check ranges'" \
        "헬스 체크 방화벽 ($FW_HEALTH)"

    echo "--- 네트워크 준비 완료 ---"
    echo ""
}

# 스크립트 디렉토리 (source 경로 해결용)
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
