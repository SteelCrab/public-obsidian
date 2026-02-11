#!/bin/bash
# GCP 심플 VM 모듈: Public 1대 + Private 1대
# 독립 실행 가능 (ensure_network로 VPC 자동 생성)

set -e
source "$(dirname "$0")/gcp-env.sh"

banner "심플 VM 구성 (Public: $SIMPLE_PUBLIC_VM / Private: $SIMPLE_PRIVATE_VM)"

# ==================== 1. 네트워크 확인/생성 ====================
ensure_network

# ==================== 2. Public VM 생성 ====================
step 1 2 "Public VM 생성 중... ($SIMPLE_PUBLIC_VM)"

create_if_not_exists \
    "gcloud compute instances describe $SIMPLE_PUBLIC_VM --zone=$ZONE" \
    "gcloud compute instances create $SIMPLE_PUBLIC_VM \
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
apt-get update && apt-get install -y nginx
HOSTNAME=\$(hostname)
IP=\$(hostname -I | awk \"{print \\\$1}\")
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>\$HOSTNAME</title>
<style>body{font-family:Arial;text-align:center;padding:50px;background:#e8f5e9;}h1{color:#2e7d32;}.info{background:white;padding:20px;border-radius:8px;display:inline-block;}</style>
</head>
<body>
<h1>Public Nginx</h1>
<div class=\"info\">
<p><b>Host:</b> \$HOSTNAME</p>
<p><b>IP:</b> \$IP</p>
<p><b>Subnet:</b> public-subnet</p>
</div>
</body></html>
EOF
systemctl restart nginx
'" \
    "Public VM ($SIMPLE_PUBLIC_VM)"

# ==================== 3. Private VM 생성 ====================
step 2 2 "Private VM 생성 중... ($SIMPLE_PRIVATE_VM)"

create_if_not_exists \
    "gcloud compute instances describe $SIMPLE_PRIVATE_VM --zone=$ZONE" \
    "gcloud compute instances create $SIMPLE_PRIVATE_VM \
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
apt-get update && apt-get install -y nginx
HOSTNAME=\$(hostname)
IP=\$(hostname -I | awk \"{print \\\$1}\")
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>\$HOSTNAME</title>
<style>body{font-family:Arial;text-align:center;padding:50px;background:#e3f2fd;}h1{color:#1565c0;}.info{background:white;padding:20px;border-radius:8px;display:inline-block;}</style>
</head>
<body>
<h1>Private Nginx</h1>
<div class=\"info\">
<p><b>Host:</b> \$HOSTNAME</p>
<p><b>IP:</b> \$IP</p>
<p><b>Subnet:</b> private-subnet</p>
</div>
</body></html>
EOF
systemctl restart nginx
'" \
    "Private VM ($SIMPLE_PRIVATE_VM)"

# ==================== 결과 출력 ====================
PUB_EXT_IP=$(gcloud compute instances describe $SIMPLE_PUBLIC_VM \
    --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
PUB_INT_IP=$(gcloud compute instances describe $SIMPLE_PUBLIC_VM \
    --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')
PRIV_INT_IP=$(gcloud compute instances describe $SIMPLE_PRIVATE_VM \
    --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')

done_banner "심플 VM 구성 완료!"
echo ""
echo "┌─ public-subnet (10.0.1.0/24) ──────────┐"
echo "│  $SIMPLE_PUBLIC_VM                          │"
echo "│  External: $PUB_EXT_IP               │"
echo "│  Internal: $PUB_INT_IP                     │"
echo "└────────────────────────────────────────┘"
echo ""
echo "┌─ private-subnet (10.0.2.0/24) ─────────┐"
echo "│  $SIMPLE_PRIVATE_VM                         │"
echo "│  Internal: $PRIV_INT_IP (외부 IP 없음)       │"
echo "│  → Cloud NAT로 아웃바운드 인터넷 가능      │"
echo "└────────────────────────────────────────┘"
echo ""
echo "--- 테스트 ---"
echo ""
echo "1) Public 외부 접속:"
echo "   curl http://$PUB_EXT_IP"
echo ""
echo "2) Public SSH:"
echo "   gcloud compute ssh $SIMPLE_PUBLIC_VM --zone=$ZONE"
echo ""
echo "3) Public → Private 내부 통신:"
echo "   gcloud compute ssh $SIMPLE_PUBLIC_VM --zone=$ZONE \\"
echo "       --command=\"curl http://$PRIV_INT_IP\""
echo ""
echo "4) Private SSH (Bastion 경유):"
echo "   gcloud compute ssh $SIMPLE_PUBLIC_VM --zone=$ZONE"
echo "   ssh $PRIV_INT_IP"
echo ""
echo "정리: bash gcp-simple-cleanup.sh"
echo "=========================================="
