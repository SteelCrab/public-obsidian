#!/bin/bash
# GCP Load Balancer 모듈 정리: LB 전체 리소스 삭제
# Forwarding → Proxy → URL Map → Backend → MIG → Health Check → Template → IP
# VPC/서브넷/NAT는 공유 리소스이므로 유지

set -e
trap 'echo "⚠ 에러 발생. 일부 리소스가 남아있을 수 있습니다."' ERR
source "$(dirname "$0")/gcp-env.sh"

banner "Load Balancer 리소스 삭제"

# ==================== LB 리소스 삭제 (역순) ====================
step 1 8 "Forwarding Rule 삭제..."
delete_if_exists \
    "gcloud compute forwarding-rules describe $FORWARDING_RULE --global" \
    "gcloud compute forwarding-rules delete $FORWARDING_RULE --global --quiet" \
    "$FORWARDING_RULE"

step 2 8 "HTTP Proxy 삭제..."
delete_if_exists \
    "gcloud compute target-http-proxies describe $HTTP_PROXY" \
    "gcloud compute target-http-proxies delete $HTTP_PROXY --quiet" \
    "$HTTP_PROXY"

step 3 8 "URL Map 삭제..."
delete_if_exists \
    "gcloud compute url-maps describe $URL_MAP" \
    "gcloud compute url-maps delete $URL_MAP --quiet" \
    "$URL_MAP"

step 4 8 "Backend Service 삭제..."
delete_if_exists \
    "gcloud compute backend-services describe $BACKEND_SERVICE --global" \
    "gcloud compute backend-services delete $BACKEND_SERVICE --global --quiet" \
    "$BACKEND_SERVICE"

step 5 8 "MIG 삭제..."
delete_if_exists \
    "gcloud compute instance-groups managed describe $MIG_NAME --region=$REGION" \
    "gcloud compute instance-groups managed delete $MIG_NAME --region=$REGION --quiet" \
    "$MIG_NAME"

step 6 8 "헬스 체크 삭제..."
delete_if_exists \
    "gcloud compute health-checks describe $HEALTH_CHECK" \
    "gcloud compute health-checks delete $HEALTH_CHECK --quiet" \
    "$HEALTH_CHECK"

step 7 8 "인스턴스 템플릿 삭제..."
delete_if_exists \
    "gcloud compute instance-templates describe $TEMPLATE_NAME" \
    "gcloud compute instance-templates delete $TEMPLATE_NAME --quiet" \
    "$TEMPLATE_NAME"

step 8 8 "전역 IP 삭제..."
delete_if_exists \
    "gcloud compute addresses describe $LB_IP_NAME --global" \
    "gcloud compute addresses delete $LB_IP_NAME --global --quiet" \
    "$LB_IP_NAME"

done_banner "Load Balancer 정리 완료!"
echo ""
echo "VPC/서브넷/NAT/방화벽은 유지됩니다."
echo "네트워크 삭제: bash gcp-network-cleanup.sh"
echo "=========================================="
