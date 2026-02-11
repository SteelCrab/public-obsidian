#!/bin/bash
# GCP GCS 모듈 정리: Cloud Storage + Load Balancer 삭제
# LB 리소스 → 버킷 순서로 삭제

set -e
trap 'echo "⚠ 에러 발생. 일부 리소스가 남아있을 수 있습니다."' ERR
source "$(dirname "$0")/gcp-env.sh"

banner "GCS + LB 리소스 삭제"

# ==================== LB 리소스 삭제 (역순) ====================
step 1 6 "Forwarding Rule 삭제..."
delete_if_exists \
    "gcloud compute forwarding-rules describe $GCS_FORWARDING_RULE --global" \
    "gcloud compute forwarding-rules delete $GCS_FORWARDING_RULE --global --quiet" \
    "Forwarding Rule ($GCS_FORWARDING_RULE)"

step 2 6 "HTTP Proxy 삭제..."
delete_if_exists \
    "gcloud compute target-http-proxies describe $GCS_HTTP_PROXY" \
    "gcloud compute target-http-proxies delete $GCS_HTTP_PROXY --quiet" \
    "HTTP Proxy ($GCS_HTTP_PROXY)"

step 3 6 "URL Map 삭제..."
delete_if_exists \
    "gcloud compute url-maps describe $GCS_URL_MAP" \
    "gcloud compute url-maps delete $GCS_URL_MAP --quiet" \
    "URL Map ($GCS_URL_MAP)"

step 4 6 "백엔드 버킷 삭제..."
delete_if_exists \
    "gcloud compute backend-buckets describe $GCS_BACKEND_BUCKET" \
    "gcloud compute backend-buckets delete $GCS_BACKEND_BUCKET --quiet" \
    "백엔드 버킷 ($GCS_BACKEND_BUCKET)"

step 5 6 "전역 IP 삭제..."
delete_if_exists \
    "gcloud compute addresses describe $GCS_LB_IP --global" \
    "gcloud compute addresses delete $GCS_LB_IP --global --quiet" \
    "전역 IP ($GCS_LB_IP)"

# ==================== Cloud Storage 버킷 삭제 ====================
step 6 6 "Cloud Storage 버킷 삭제..."
delete_if_exists \
    "gcloud storage buckets describe gs://$GCS_BUCKET" \
    "gcloud storage rm --recursive gs://$GCS_BUCKET" \
    "버킷 및 객체 (gs://$GCS_BUCKET)"

done_banner "GCS + LB 리소스 정리 완료!"
echo ""
echo "VPC는 이 스크립트에서 사용하지 않으므로 별도 정리 불필요."
echo "=========================================="
