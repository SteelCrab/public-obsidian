#!/bin/bash
# GCP 공유 네트워크 정리: 방화벽 → NAT → Router → 서브넷 → VPC 삭제
# 주의: 모든 모듈 리소스(VM, SQL, LB 등)를 먼저 삭제한 후 실행
#
# 권장 순서:
#   bash gcp-vm-cleanup.sh        # VM 삭제
#   bash gcp-cloudsql-cleanup.sh  # Cloud SQL 삭제
#   bash gcp-lb-cleanup.sh        # LB 삭제
#   bash gcp-simple-cleanup.sh    # 심플 VM 삭제
#   bash gcp-network-cleanup.sh   # 네트워크 삭제 (이 스크립트)

set -e
trap 'echo "⚠ 에러 발생. 일부 리소스가 남아있을 수 있습니다."' ERR
source "$(dirname "$0")/gcp-env.sh"

banner "공유 네트워크 리소스 삭제"

# ==================== 방화벽 규칙 삭제 ====================
step 1 5 "방화벽 규칙 삭제..."
for RULE in $FW_SSH $FW_HTTP $FW_INTERNAL $FW_HEALTH; do
    delete_if_exists \
        "gcloud compute firewall-rules describe $RULE" \
        "gcloud compute firewall-rules delete $RULE --quiet" \
        "$RULE"
done

# ==================== Cloud NAT 삭제 ====================
step 2 5 "Cloud NAT 삭제..."
delete_if_exists \
    "gcloud compute routers nats describe $NAT_NAME --router=$ROUTER_NAME --region=$REGION" \
    "gcloud compute routers nats delete $NAT_NAME --router=$ROUTER_NAME --region=$REGION --quiet" \
    "Cloud NAT ($NAT_NAME)"

# ==================== Cloud Router 삭제 ====================
step 3 5 "Cloud Router 삭제..."
delete_if_exists \
    "gcloud compute routers describe $ROUTER_NAME --region=$REGION" \
    "gcloud compute routers delete $ROUTER_NAME --region=$REGION --quiet" \
    "$ROUTER_NAME"

# ==================== 서브넷 삭제 ====================
step 4 5 "서브넷 삭제..."
for SUBNET in $PUBLIC_SUBNET $PRIVATE_SUBNET; do
    delete_if_exists \
        "gcloud compute networks subnets describe $SUBNET --region=$REGION" \
        "gcloud compute networks subnets delete $SUBNET --region=$REGION --quiet" \
        "$SUBNET"
done

# ==================== VPC 삭제 ====================
step 5 5 "VPC 삭제..."
delete_if_exists \
    "gcloud compute networks describe $VPC_NAME" \
    "gcloud compute networks delete $VPC_NAME --quiet" \
    "$VPC_NAME"

done_banner "공유 네트워크 정리 완료!"
