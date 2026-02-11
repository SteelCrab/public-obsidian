#!/bin/bash
# GCP Cloud SQL 모듈 정리: Cloud SQL + Private Service Access 삭제
# VPC/서브넷/NAT는 공유 리소스이므로 유지

set -e
trap 'echo "⚠ 에러 발생. 일부 리소스가 남아있을 수 있습니다."' ERR
source "$(dirname "$0")/gcp-env.sh"

banner "Cloud SQL 리소스 삭제"

# ==================== Cloud SQL 삭제 ====================
step 1 2 "Cloud SQL 인스턴스 삭제... (최대 5분 소요)"
delete_if_exists \
    "gcloud sql instances describe $SQL_INSTANCE" \
    "gcloud sql instances delete $SQL_INSTANCE --quiet" \
    "$SQL_INSTANCE"

step 2 2 "Private Service Access IP 범위 삭제..."
delete_if_exists \
    "gcloud compute addresses describe google-managed-services-$VPC_NAME --global" \
    "gcloud compute addresses delete google-managed-services-$VPC_NAME --global --quiet" \
    "google-managed-services-$VPC_NAME"

done_banner "Cloud SQL 정리 완료!"
echo ""
echo "VPC/서브넷/NAT/방화벽은 유지됩니다."
echo "네트워크 삭제: bash gcp-network-cleanup.sh"
echo "=========================================="
