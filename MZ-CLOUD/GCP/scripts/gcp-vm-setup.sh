#!/bin/bash
# GCP VM 모듈: VPC 네트워크 + VM 인스턴스 구축
# 독립 실행 가능 (ensure_network로 VPC 자동 생성)

set -e
source "$(dirname "$0")/gcp-env.sh"

banner "VPC + VM 인스턴스 구축"

# ==================== 1. 네트워크 확인/생성 ====================
ensure_network

# ==================== 2. Public 인스턴스 생성 ====================
step 1 2 "Public 인스턴스 생성 중..."

create_if_not_exists \
    "gcloud compute instances describe $PUBLIC_INSTANCE --zone=$ZONE" \
    "gcloud compute instances create $PUBLIC_INSTANCE \
        --zone=$ZONE \
        --machine-type=e2-micro \
        --subnet=$PUBLIC_SUBNET \
        --network-tier=PREMIUM \
        --tags=http-server \
        --image-family=ubuntu-2204-lts \
        --image-project=ubuntu-os-cloud \
        --boot-disk-size=10GB \
        --boot-disk-type=pd-standard \
        --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Public Nginx Server</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; background: #f0f0f0; }
        h1 { color: #4CAF50; }
    </style>
</head>
<body>
    <h1>Public Nginx Server</h1>
    <p>Hostname: \$(hostname)</p>
    <p>IP: \$(hostname -I)</p>
    <p>Date: \$(date)</p>
</body>
</html>
EOF
systemctl restart nginx
'" \
    "Public 인스턴스 ($PUBLIC_INSTANCE)"

# ==================== 3. Private 인스턴스 생성 ====================
step 2 2 "Private 인스턴스 생성 중..."

create_if_not_exists \
    "gcloud compute instances describe $PRIVATE_INSTANCE --zone=$ZONE" \
    "gcloud compute instances create $PRIVATE_INSTANCE \
        --zone=$ZONE \
        --machine-type=e2-micro \
        --subnet=$PRIVATE_SUBNET \
        --no-address \
        --tags=http-server \
        --image-family=ubuntu-2204-lts \
        --image-project=ubuntu-os-cloud \
        --boot-disk-size=10GB \
        --boot-disk-type=pd-standard \
        --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Private Nginx Server</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; background: #e3f2fd; }
        h1 { color: #2196F3; }
    </style>
</head>
<body>
    <h1>Private Nginx Server</h1>
    <p>Hostname: \$(hostname)</p>
    <p>IP: \$(hostname -I)</p>
    <p>Date: \$(date)</p>
</body>
</html>
EOF
systemctl restart nginx
'" \
    "Private 인스턴스 ($PRIVATE_INSTANCE)"

# ==================== 결과 출력 ====================
PUBLIC_IP=$(gcloud compute instances describe $PUBLIC_INSTANCE \
    --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
PUBLIC_INTERNAL=$(gcloud compute instances describe $PUBLIC_INSTANCE \
    --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')
PRIVATE_INTERNAL=$(gcloud compute instances describe $PRIVATE_INSTANCE \
    --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')

done_banner "VPC + VM 구축 완료!"
echo ""
echo "Public Nginx:  $PUBLIC_IP (외부) / $PUBLIC_INTERNAL (내부)"
echo "Private Nginx: $PRIVATE_INTERNAL (내부 전용)"
echo ""
echo "테스트: curl http://$PUBLIC_IP"
echo "SSH:   gcloud compute ssh $PUBLIC_INSTANCE --zone=$ZONE"
echo ""
echo "정리: bash gcp-vm-cleanup.sh"
echo "=========================================="
