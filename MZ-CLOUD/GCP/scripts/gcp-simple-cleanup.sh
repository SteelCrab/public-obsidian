#!/bin/bash
# GCP 심플 VM 모듈 정리: VM만 삭제
# VPC/서브넷/NAT는 공유 리소스이므로 유지
# VPC까지 삭제하려면 gcp-network-cleanup.sh 사용

set -e
trap 'echo "⚠ 에러 발생. 일부 리소스가 남아있을 수 있습니다."' ERR
source "$(dirname "$0")/gcp-env.sh"

banner "심플 VM 삭제"

# ==================== VM 삭제 ====================
step 1 2 "Public VM 삭제..."
delete_if_exists \
    "gcloud compute instances describe $SIMPLE_PUBLIC_VM --zone=$ZONE" \
    "gcloud compute instances delete $SIMPLE_PUBLIC_VM --zone=$ZONE --quiet" \
    "$SIMPLE_PUBLIC_VM"

step 2 2 "Private VM 삭제..."
delete_if_exists \
    "gcloud compute instances describe $SIMPLE_PRIVATE_VM --zone=$ZONE" \
    "gcloud compute instances delete $SIMPLE_PRIVATE_VM --zone=$ZONE --quiet" \
    "$SIMPLE_PRIVATE_VM"

done_banner "심플 VM 정리 완료!"
echo ""
echo "VPC/서브넷/NAT/방화벽은 유지됩니다."
echo "네트워크 삭제: bash gcp-network-cleanup.sh"
echo "=========================================="
