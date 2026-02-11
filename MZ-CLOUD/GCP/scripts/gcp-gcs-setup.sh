#!/bin/bash
# GCP GCS 모듈: Cloud Storage + Load Balancer (정적 사이트)
# Cloud Storage 버킷을 백엔드로 사용하는 HTTP(S) LB 구성
# 독립 실행 가능 (VPC 불필요)

set -e
source "$(dirname "$0")/gcp-env.sh"

banner "Cloud Storage + Load Balancer 구축"

# ==================== 1. Cloud Storage 버킷 생성 ====================
step 1 7 "Cloud Storage 버킷 생성 중..."

create_if_not_exists \
    "gcloud storage buckets describe gs://$GCS_BUCKET" \
    "gcloud storage buckets create gs://$GCS_BUCKET \
        --location=$REGION \
        --default-storage-class=STANDARD \
        --uniform-bucket-level-access" \
    "GCS 버킷 ($GCS_BUCKET)"

# ==================== 2. 버킷 공개 설정 ====================
step 2 7 "버킷 공개 접근 설정 중..."

# 공개 접근 방지 해제
gcloud storage buckets update gs://$GCS_BUCKET \
    --no-public-access-prevention 2>/dev/null || true

# allUsers에게 읽기 권한 부여
gcloud storage buckets add-iam-policy-binding gs://$GCS_BUCKET \
    --member=allUsers \
    --role=roles/storage.objectViewer 2>/dev/null || echo "  ✓ 공개 권한이 이미 설정되어 있습니다."

echo "  ✓ 버킷 공개 설정 완료"

# ==================== 3. 샘플 정적 사이트 업로드 ====================
step 3 7 "샘플 정적 사이트 업로드 중..."

# index.html 생성 및 업로드
cat > /tmp/index.html <<'HTMLEOF'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GCP Static Site</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; min-height: 100vh; margin: 0; }
        .container { background: rgba(255,255,255,0.15); padding: 40px; border-radius: 16px; display: inline-block; backdrop-filter: blur(10px); }
        h1 { font-size: 2.5em; margin-bottom: 10px; }
        p { font-size: 1.2em; opacity: 0.9; }
        .badge { background: rgba(255,255,255,0.25); padding: 8px 16px; border-radius: 20px; display: inline-block; margin: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>GCP Static Site</h1>
        <p>Cloud Storage + Load Balancer + CDN</p>
        <div>
            <span class="badge">GCS Backend</span>
            <span class="badge">Global LB</span>
            <span class="badge">Cloud CDN</span>
        </div>
    </div>
</body>
</html>
HTMLEOF

# 404 페이지 생성
cat > /tmp/404.html <<'HTMLEOF'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>404 - Not Found</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 100px; background: #f5f5f5; }
        h1 { color: #e53935; font-size: 3em; }
    </style>
</head>
<body>
    <h1>404</h1>
    <p>페이지를 찾을 수 없습니다.</p>
</body>
</html>
HTMLEOF

gcloud storage cp /tmp/index.html gs://$GCS_BUCKET/index.html
gcloud storage cp /tmp/404.html gs://$GCS_BUCKET/404.html
rm -f /tmp/index.html /tmp/404.html

# 웹사이트 설정 (MainPage, NotFoundPage)
gcloud storage buckets update gs://$GCS_BUCKET \
    --web-main-page-suffix=index.html \
    --web-error-page=404.html

echo "  ✓ 정적 사이트 업로드 완료"

# ==================== 4. 백엔드 버킷 생성 (CDN 포함) ====================
step 4 7 "백엔드 버킷 생성 중..."

create_if_not_exists \
    "gcloud compute backend-buckets describe $GCS_BACKEND_BUCKET" \
    "gcloud compute backend-buckets create $GCS_BACKEND_BUCKET \
        --gcs-bucket-name=$GCS_BUCKET \
        --enable-cdn" \
    "백엔드 버킷 ($GCS_BACKEND_BUCKET, CDN 활성화)"

# ==================== 5. URL Map 생성 ====================
step 5 7 "URL Map 생성 중..."

create_if_not_exists \
    "gcloud compute url-maps describe $GCS_URL_MAP" \
    "gcloud compute url-maps create $GCS_URL_MAP \
        --default-backend-bucket=$GCS_BACKEND_BUCKET" \
    "URL Map ($GCS_URL_MAP)"

# ==================== 6. HTTP Proxy 생성 ====================
step 6 7 "HTTP Proxy 생성 중..."

create_if_not_exists \
    "gcloud compute target-http-proxies describe $GCS_HTTP_PROXY" \
    "gcloud compute target-http-proxies create $GCS_HTTP_PROXY \
        --url-map=$GCS_URL_MAP" \
    "HTTP Proxy ($GCS_HTTP_PROXY)"

# ==================== 7. 전역 IP + Forwarding Rule ====================
step 7 7 "전역 IP 및 Forwarding Rule 생성 중..."

create_if_not_exists \
    "gcloud compute addresses describe $GCS_LB_IP --global" \
    "gcloud compute addresses create $GCS_LB_IP \
        --ip-version=IPV4 \
        --global" \
    "전역 IP ($GCS_LB_IP)"

create_if_not_exists \
    "gcloud compute forwarding-rules describe $GCS_FORWARDING_RULE --global" \
    "gcloud compute forwarding-rules create $GCS_FORWARDING_RULE \
        --address=$GCS_LB_IP \
        --target-http-proxy=$GCS_HTTP_PROXY \
        --ports=80 \
        --global" \
    "Forwarding Rule ($GCS_FORWARDING_RULE)"

# ==================== 결과 출력 ====================
LB_IP=$(gcloud compute addresses describe $GCS_LB_IP --global \
    --format="value(address)")

done_banner "GCS + LB 구축 완료!"
echo ""
echo "LB 외부 IP:   $LB_IP"
echo "버킷:         gs://$GCS_BUCKET"
echo "CDN:          활성화"
echo ""
echo "--- 접속 ---"
echo ""
echo "LB 경유 (프로비저닝 후 1~3분 대기):"
echo "  curl http://$LB_IP"
echo "  브라우저: http://$LB_IP"
echo ""
echo "버킷 직접 접속:"
echo "  https://storage.googleapis.com/$GCS_BUCKET/index.html"
echo ""
echo "--- HTTPS 추가 시 ---"
echo ""
echo "1) SSL 인증서 생성:"
echo "   gcloud compute ssl-certificates create my-cert \\"
echo "       --domains=example.com --global"
echo ""
echo "2) HTTPS Proxy 생성 후 Forwarding Rule 추가"
echo ""
echo "정리: bash gcp-gcs-cleanup.sh"
echo "=========================================="
