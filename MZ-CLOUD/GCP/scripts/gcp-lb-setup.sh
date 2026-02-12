#!/bin/bash
# GCP Load Balancer 모듈: HTTP(S) LB 구축 (독립 실행 가능)
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/gcp-env.sh"

banner "HTTP(S) Load Balancer 구축"

# 1. 네트워크 확인
check_network

# 2. 인스턴스 템플릿
step 1 7 "인스턴스 템플릿 ($TEMPLATE_NAME)"
create_if_not_exists \
    "gcloud compute instance-templates describe $TEMPLATE_NAME" \
    "gcloud compute instance-templates create $TEMPLATE_NAME \
        --machine-type=e2-micro --subnet=$PUBLIC_SUBNET --region=$REGION \
        --image-family=ubuntu-minimal-2404-lts-amd64 --image-project=ubuntu-os-cloud \
        --boot-disk-size=10GB --boot-disk-type=pd-standard --tags=http-server \
        --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx
cat > /var/www/html/index.html <<EOF
<h1>LB Backend: \$(hostname)</h1>
<p>Zone: \$(curl -s -H \"Metadata-Flavor: Google\" http://metadata.google.internal/computeMetadata/v1/instance/zone | cut -d/ -f4)</p>
EOF
systemctl restart nginx'" \
    "Template"

# 3. 헬스 체크
step 2 7 "헬스 체크 ($HEALTH_CHECK)"
create_if_not_exists \
    "gcloud compute health-checks describe $HEALTH_CHECK" \
    "gcloud compute health-checks create http $HEALTH_CHECK --port=80 --check-interval=10s --timeout=5s --unhealthy-threshold=3 --healthy-threshold=2" \
    "Health Check"

# 4. MIG (관리형 인스턴스 그룹)
step 3 7 "MIG 생성 ($MIG_NAME)"
if gcloud compute instance-groups managed describe $MIG_NAME --region=$REGION &>/dev/null; then
    echo "  ✓ MIG 이미 존재"
else
    gcloud compute instance-groups managed create $MIG_NAME \
        --base-instance-name=web --template=$TEMPLATE_NAME --size=2 \
        --region=$REGION --target-distribution-shape=EVEN
    
    # 설정
    gcloud compute instance-groups managed set-named-ports $MIG_NAME --named-ports=http:80 --region=$REGION
    gcloud compute instance-groups managed set-autoscaling $MIG_NAME --region=$REGION --min-num-replicas=2 --max-num-replicas=5 --target-cpu-utilization=0.75 --cool-down-period=60
    gcloud compute instance-groups managed update $MIG_NAME --region=$REGION --health-check=$HEALTH_CHECK --initial-delay=120
    echo "  ✓ MIG 생성 및 설정 완료"
fi

# 5. 백엔드 서비스
step 4 7 "백엔드 서비스 ($BACKEND_SERVICE)"
if ! gcloud compute backend-services describe $BACKEND_SERVICE --global &>/dev/null; then
    gcloud compute backend-services create $BACKEND_SERVICE --protocol=HTTP --port-name=http --health-checks=$HEALTH_CHECK --global
    gcloud compute backend-services add-backend $BACKEND_SERVICE --instance-group=$MIG_NAME --instance-group-region=$REGION --balancing-mode=UTILIZATION --max-utilization=0.8 --global
    echo "  ✓ 백엔드 서비스 생성 완료"
else
    echo "  ✓ 백엔드 서비스 이미 존재"
fi

# 6. URL Map
step 5 7 "URL Map ($URL_MAP)"
create_if_not_exists \
    "gcloud compute url-maps describe $URL_MAP" \
    "gcloud compute url-maps create $URL_MAP --default-service=$BACKEND_SERVICE" \
    "URL Map"

# 7. HTTP Proxy
step 6 7 "Target HTTP Proxy ($HTTP_PROXY)"
create_if_not_exists \
    "gcloud compute target-http-proxies describe $HTTP_PROXY" \
    "gcloud compute target-http-proxies create $HTTP_PROXY --url-map=$URL_MAP" \
    "HTTP Proxy"

# 8. Forwarding Rule
step 7 7 "Forwarding Rule ($FORWARDING_RULE)"
create_if_not_exists \
    "gcloud compute addresses describe $LB_IP_NAME --global" \
    "gcloud compute addresses create $LB_IP_NAME --ip-version=IPV4 --global" \
    "전역 IP"

create_if_not_exists \
    "gcloud compute forwarding-rules describe $FORWARDING_RULE --global" \
    "gcloud compute forwarding-rules create $FORWARDING_RULE --address=$LB_IP_NAME --target-http-proxy=$HTTP_PROXY --ports=80 --global" \
    "Forwarding Rule"

# 결과 출력
LB_IP=$(gcloud compute addresses describe $LB_IP_NAME --global --format="value(address)")

done_banner "설정 완료"
echo "LB IP: $LB_IP (curl http://$LB_IP)"
echo "테스트: for i in \$(seq 1 10); do curl -s http://$LB_IP | grep Backend; done"
echo "정리:  bash gcp-lb-cleanup.sh"
echo "=========================================="
