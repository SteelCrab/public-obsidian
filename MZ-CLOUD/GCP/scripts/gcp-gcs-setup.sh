#!/bin/bash
# GCP GCS 모듈: Cloud Storage + Load Balancer + CDN (독립 실행, VPC 불필요)
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/gcp-env.sh"

banner "Cloud Storage + Load Balancer 구축"

# 1. 버킷 생성 및 설정
step 1 4 "버킷 생성 ($GCS_BUCKET)"
create_if_not_exists \
    "gcloud storage buckets describe gs://$GCS_BUCKET" \
    "gcloud storage buckets create gs://$GCS_BUCKET --location=$REGION --default-storage-class=STANDARD --uniform-bucket-level-access" \
    "GCS 버킷"

# 공개 설정
gcloud storage buckets update gs://$GCS_BUCKET --no-public-access-prevention 2>/dev/null || true
gcloud storage buckets add-iam-policy-binding gs://$GCS_BUCKET --member=allUsers --role=roles/storage.objectViewer 2>/dev/null || true
echo "  ✓ 공개 권한 설정 완료"

# 파일 업로드 (index.html, 404.html)
echo "<h1>Welcome to GCS Static Site</h1><p>Served via Cloud CDN</p>" > /tmp/index.html
echo "<h1>404 Not Found</h1>" > /tmp/404.html
gcloud storage cp /tmp/index.html gs://$GCS_BUCKET/index.html
gcloud storage cp /tmp/404.html gs://$GCS_BUCKET/404.html
rm -f /tmp/index.html /tmp/404.html
gcloud storage buckets update gs://$GCS_BUCKET --web-main-page-suffix=index.html --web-error-page=404.html
echo "  ✓ 정적 파일 업로드 완료"

# 2. 백엔드 버킷 (CDN)
step 2 4 "백엔드 버킷 ($GCS_BACKEND_BUCKET)"
create_if_not_exists \
    "gcloud compute backend-buckets describe $GCS_BACKEND_BUCKET" \
    "gcloud compute backend-buckets create $GCS_BACKEND_BUCKET --gcs-bucket-name=$GCS_BUCKET --enable-cdn" \
    "Backend Bucket (CDN)"

# 3. URL Map + Proxy
step 3 4 "URL Map & Proxy"
create_if_not_exists \
    "gcloud compute url-maps describe $GCS_URL_MAP" \
    "gcloud compute url-maps create $GCS_URL_MAP --default-backend-bucket=$GCS_BACKEND_BUCKET" \
    "URL Map"

create_if_not_exists \
    "gcloud compute target-http-proxies describe $GCS_HTTP_PROXY" \
    "gcloud compute target-http-proxies create $GCS_HTTP_PROXY --url-map=$GCS_URL_MAP" \
    "HTTP Proxy"

# 4. Forwarding Rule
step 4 4 "Forwarding Rule ($GCS_FORWARDING_RULE)"
create_if_not_exists \
    "gcloud compute addresses describe $GCS_LB_IP --global" \
    "gcloud compute addresses create $GCS_LB_IP --ip-version=IPV4 --global" \
    "전역 IP"

create_if_not_exists \
    "gcloud compute forwarding-rules describe $GCS_FORWARDING_RULE --global" \
    "gcloud compute forwarding-rules create $GCS_FORWARDING_RULE --address=$GCS_LB_IP --target-http-proxy=$GCS_HTTP_PROXY --ports=80 --global" \
    "Forwarding Rule"

# 결과
LB_IP=$(gcloud compute addresses describe $GCS_LB_IP --global --format="value(address)")

done_banner "설정 완료"
echo "LB IP:  $LB_IP (http://$LB_IP)"
echo "Bucket: gs://$GCS_BUCKET"
echo "정리:   bash gcp-gcs-cleanup.sh"
echo "=========================================="
