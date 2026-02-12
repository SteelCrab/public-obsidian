#!/bin/bash
# GCP VM 모듈: Public + Private VM (독립 실행 가능)
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/gcp-env.sh"

banner "VPC + VM 인스턴스 구축"

# 1. 네트워크 확인
check_network

# 2. Public VM
step 1 2 "Public VM 생성 ($PUBLIC_INSTANCE)"
if gcloud compute instances describe $PUBLIC_INSTANCE --zone=$ZONE &>/dev/null; then
    echo "  ✓ Public VM 이미 존재"
else
    gcloud compute instances create $PUBLIC_INSTANCE \
        --zone=$ZONE --machine-type=e2-micro --subnet=$PUBLIC_SUBNET \
        --network-tier=PREMIUM --tags=http-server \
        --image-family=ubuntu-minimal-2404-lts-amd64 --image-project=ubuntu-os-cloud \
        --boot-disk-size=10GB --boot-disk-type=pd-standard \
        --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx
echo "<h1>Public Nginx: $(hostname)</h1><p>IP: $(hostname -I)</p>" > /var/www/html/index.html
systemctl restart nginx'
    echo "  ✓ Public VM 생성 완료"
fi

# 3. Private VM
step 2 2 "Private VM 생성 ($PRIVATE_INSTANCE)"
if gcloud compute instances describe $PRIVATE_INSTANCE --zone=$ZONE &>/dev/null; then
    echo "  ✓ Private VM 이미 존재"
else
    gcloud compute instances create $PRIVATE_INSTANCE \
        --zone=$ZONE --machine-type=e2-micro --subnet=$PRIVATE_SUBNET \
        --no-address --tags=http-server \
        --image-family=ubuntu-minimal-2404-lts-amd64 --image-project=ubuntu-os-cloud \
        --boot-disk-size=10GB --boot-disk-type=pd-standard \
        --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx
echo "<h1>Private Nginx: $(hostname)</h1><p>IP: $(hostname -I)</p>" > /var/www/html/index.html
systemctl restart nginx'
    echo "  ✓ Private VM 생성 완료"
fi

# 결과 출력
PUBLIC_IP=$(gcloud compute instances describe $PUBLIC_INSTANCE --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
PRIVATE_IP=$(gcloud compute instances describe $PRIVATE_INSTANCE --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')

done_banner "설정 완료"
echo "Public:  $PUBLIC_IP (curl http://$PUBLIC_IP)"
echo "Private: $PRIVATE_IP (Internal Only)"
echo "------------------------------------------"
echo "[접속 가이드]"
echo "1. Public VM 접속:"
echo "   gcloud compute ssh $PUBLIC_INSTANCE --zone=$ZONE"
echo "2. Private VM 통신 확인 (Public VM 내부에서):"
echo "   curl http://$PRIVATE_IP"
echo "3. 로컬 포트 포워딩 (http://localhost:8080):"
echo "   gcloud compute ssh $PUBLIC_INSTANCE --zone=$ZONE -- -L 8080:$PRIVATE_IP:80"
echo "------------------------------------------"
echo "정리:    bash gcp-vm-cleanup.sh"
echo "=========================================="

