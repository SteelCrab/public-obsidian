#!/bin/bash
# GCP Load Balancer 모듈: HTTP(S) Load Balancer 구축
# 독립 실행 가능 (ensure_network로 VPC/서브넷 자동 생성)

set -e
source "$(dirname "$0")/gcp-env.sh"

banner "HTTP(S) Load Balancer 구축"

# ==================== 1. 네트워크 확인/생성 ====================
ensure_network

# ==================== 2. 인스턴스 템플릿 생성 ====================
step 1 7 "인스턴스 템플릿 생성 중..."

create_if_not_exists \
    "gcloud compute instance-templates describe $TEMPLATE_NAME" \
    "gcloud compute instance-templates create $TEMPLATE_NAME \
        --machine-type=e2-micro \
        --subnet=projects/$PROJECT_ID/regions/$REGION/subnetworks/$PUBLIC_SUBNET \
        --region=$REGION \
        --image-family=ubuntu-2204-lts \
        --image-project=ubuntu-os-cloud \
        --boot-disk-size=10GB \
        --boot-disk-type=pd-standard \
        --tags=http-server \
        --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx

INSTANCE_NAME=\$(curl -s -H \"Metadata-Flavor: Google\" http://metadata.google.internal/computeMetadata/v1/instance/name)
INSTANCE_ZONE=\$(curl -s -H \"Metadata-Flavor: Google\" http://metadata.google.internal/computeMetadata/v1/instance/zone | cut -d/ -f4)
INSTANCE_IP=\$(curl -s -H \"Metadata-Flavor: Google\" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Web Server - Load Balanced</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; background: #e8f5e9; }
        h1 { color: #388E3C; }
        .info { background: white; padding: 20px; border-radius: 8px; display: inline-block; }
    </style>
</head>
<body>
    <h1>Web Server (Load Balanced)</h1>
    <div class=\"info\">
        <p><b>Instance:</b> \$INSTANCE_NAME</p>
        <p><b>Zone:</b> \$INSTANCE_ZONE</p>
        <p><b>Internal IP:</b> \$INSTANCE_IP</p>
        <p><b>Time:</b> \$(date)</p>
    </div>
</body>
</html>
EOF
systemctl restart nginx
'" \
    "인스턴스 템플릿 ($TEMPLATE_NAME)"

# ==================== 3. 헬스 체크 생성 ====================
step 2 7 "헬스 체크 생성 중..."

create_if_not_exists \
    "gcloud compute health-checks describe $HEALTH_CHECK" \
    "gcloud compute health-checks create http $HEALTH_CHECK --port=80 --request-path=/ --check-interval=10s --timeout=5s --unhealthy-threshold=3 --healthy-threshold=2" \
    "헬스 체크 ($HEALTH_CHECK)"

# ==================== 4. MIG (관리형 인스턴스 그룹) 생성 ====================
step 3 7 "MIG 생성 중..."

if gcloud compute instance-groups managed describe $MIG_NAME --region=$REGION &>/dev/null; then
    echo "  ✓ MIG ($MIG_NAME) 이미 존재"
else
    gcloud compute instance-groups managed create $MIG_NAME \
        --base-instance-name=web \
        --template=$TEMPLATE_NAME \
        --size=2 \
        --region=$REGION \
        --target-distribution-shape=EVEN
    echo "  ✓ MIG ($MIG_NAME) 생성 완료 (인스턴스 2개)"

    # Named Port 설정 (LB 백엔드에서 사용)
    gcloud compute instance-groups managed set-named-ports $MIG_NAME \
        --named-ports=http:80 \
        --region=$REGION
    echo "  ✓ Named Port (http:80) 설정 완료"

    # 자동 확장 설정
    gcloud compute instance-groups managed set-autoscaling $MIG_NAME \
        --region=$REGION \
        --min-num-replicas=2 \
        --max-num-replicas=5 \
        --target-cpu-utilization=0.75 \
        --cool-down-period=60
    echo "  ✓ 자동 확장 설정 완료 (min:2, max:5, CPU 75%)"

    # 자동 복구 설정
    gcloud compute instance-groups managed update $MIG_NAME \
        --region=$REGION \
        --health-check=$HEALTH_CHECK \
        --initial-delay=120
    echo "  ✓ 자동 복구 설정 완료"
fi

# ==================== 5. 백엔드 서비스 생성 ====================
step 4 7 "백엔드 서비스 생성 중..."

if gcloud compute backend-services describe $BACKEND_SERVICE --global &>/dev/null; then
    echo "  ✓ 백엔드 서비스 ($BACKEND_SERVICE) 이미 존재"
else
    gcloud compute backend-services create $BACKEND_SERVICE \
        --protocol=HTTP \
        --port-name=http \
        --health-checks=$HEALTH_CHECK \
        --global

    gcloud compute backend-services add-backend $BACKEND_SERVICE \
        --instance-group=$MIG_NAME \
        --instance-group-region=$REGION \
        --balancing-mode=UTILIZATION \
        --max-utilization=0.8 \
        --global
    echo "  ✓ 백엔드 서비스 ($BACKEND_SERVICE) 생성 및 MIG 연결 완료"
fi

# ==================== 6. URL Map 생성 ====================
step 5 7 "URL Map 생성 중..."

create_if_not_exists \
    "gcloud compute url-maps describe $URL_MAP" \
    "gcloud compute url-maps create $URL_MAP --default-service=$BACKEND_SERVICE" \
    "URL Map ($URL_MAP)"

# ==================== 7. Target HTTP Proxy 생성 ====================
step 6 7 "Target HTTP Proxy 생성 중..."

create_if_not_exists \
    "gcloud compute target-http-proxies describe $HTTP_PROXY" \
    "gcloud compute target-http-proxies create $HTTP_PROXY --url-map=$URL_MAP" \
    "HTTP Proxy ($HTTP_PROXY)"

# ==================== 8. 전역 IP + Forwarding Rule 생성 ====================
step 7 7 "전역 IP 및 Forwarding Rule 생성 중..."

create_if_not_exists \
    "gcloud compute addresses describe $LB_IP_NAME --global" \
    "gcloud compute addresses create $LB_IP_NAME --ip-version=IPV4 --global" \
    "전역 IP ($LB_IP_NAME)"

create_if_not_exists \
    "gcloud compute forwarding-rules describe $FORWARDING_RULE --global" \
    "gcloud compute forwarding-rules create $FORWARDING_RULE --address=$LB_IP_NAME --target-http-proxy=$HTTP_PROXY --ports=80 --global" \
    "Forwarding Rule ($FORWARDING_RULE)"

# ==================== 결과 출력 ====================
LB_IP=$(gcloud compute addresses describe $LB_IP_NAME --global \
    --format="value(address)")

done_banner "Load Balancer 구축 완료!"
echo ""
echo "LB 외부 IP:     $LB_IP"
echo "URL Map:        $URL_MAP"
echo "Backend:        $BACKEND_SERVICE"
echo "MIG:            $MIG_NAME (2~5 인스턴스)"
echo "Health Check:   $HEALTH_CHECK"
echo ""
echo "--- 테스트 ---"
echo ""
echo "LB 접속 (프로비저닝 후 1~3분 대기):"
echo "  curl http://$LB_IP"
echo "  브라우저: http://$LB_IP"
echo ""
echo "여러 번 요청하면 다른 인스턴스로 분산되는 것을 확인:"
echo "  for i in \$(seq 1 10); do curl -s http://$LB_IP | grep Instance; done"
echo ""
echo "MIG 인스턴스 목록:"
echo "  gcloud compute instance-groups managed list-instances $MIG_NAME --region=$REGION"
echo ""
echo "백엔드 헬스 상태:"
echo "  gcloud compute backend-services get-health $BACKEND_SERVICE --global"
echo ""
echo "정리: bash gcp-lb-cleanup.sh"
echo "=========================================="
