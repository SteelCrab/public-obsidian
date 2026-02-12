#!/bin/bash
# GCP 네트워크 모듈: VPC + Subnet + Router + NAT + Firewall
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/gcp-env.sh"

banner "GCP 네트워크 구축"

# 1. VPC
create_if_not_exists \
    "gcloud compute networks describe $VPC_NAME" \
    "gcloud compute networks create $VPC_NAME --subnet-mode=custom --bgp-routing-mode=regional" \
    "VPC ($VPC_NAME)"

# 2. Subnets
create_if_not_exists \
    "gcloud compute networks subnets describe $PUBLIC_SUBNET --region=$REGION" \
    "gcloud compute networks subnets create $PUBLIC_SUBNET --network=$VPC_NAME --region=$REGION --range=10.0.1.0/24" \
    "Public Subnet"

create_if_not_exists \
    "gcloud compute networks subnets describe $PRIVATE_SUBNET --region=$REGION" \
    "gcloud compute networks subnets create $PRIVATE_SUBNET --network=$VPC_NAME --region=$REGION --range=10.0.2.0/24 --enable-private-ip-google-access" \
    "Private Subnet"

# 3. Router & NAT
create_if_not_exists \
    "gcloud compute routers describe $ROUTER_NAME --region=$REGION" \
    "gcloud compute routers create $ROUTER_NAME --network=$VPC_NAME --region=$REGION" \
    "Cloud Router"

create_if_not_exists \
    "gcloud compute routers nats describe $NAT_NAME --router=$ROUTER_NAME --region=$REGION" \
    "gcloud compute routers nats create $NAT_NAME --router=$ROUTER_NAME --region=$REGION --nat-all-subnet-ip-ranges --auto-allocate-nat-external-ips --auto-allocate-nat-external-ips" \
    "Cloud NAT"

# 4. Firewall Rules
create_if_not_exists \
    "gcloud compute firewall-rules describe $FW_SSH" \
    "gcloud compute firewall-rules create $FW_SSH --network=$VPC_NAME --allow=tcp:22 --source-ranges=0.0.0.0/0 --description='Allow SSH'" \
    "FW: SSH"

create_if_not_exists \
    "gcloud compute firewall-rules describe $FW_HTTP" \
    "gcloud compute firewall-rules create $FW_HTTP --network=$VPC_NAME --allow=tcp:80,tcp:443 --source-ranges=0.0.0.0/0 --target-tags=http-server" \
    "FW: HTTP"

create_if_not_exists \
    "gcloud compute firewall-rules describe $FW_INTERNAL" \
    "gcloud compute firewall-rules create $FW_INTERNAL --network=$VPC_NAME --allow=tcp:0-65535,udp:0-65535,icmp --source-ranges=10.0.0.0/8" \
    "FW: Internal"

create_if_not_exists \
    "gcloud compute firewall-rules describe $FW_HEALTH" \
    "gcloud compute firewall-rules create $FW_HEALTH --network=$VPC_NAME --allow=tcp:80 --source-ranges=130.211.0.0/22,35.191.0.0/16 --target-tags=http-server" \
    "FW: Health Check"

done_banner "네트워크 설정 완료"
echo "VPC: $VPC_NAME"
echo "Subnets: $PUBLIC_SUBNET, $PRIVATE_SUBNET"
echo "NAT: $NAT_NAME"
echo "정리: bash gcp-network-cleanup.sh"
echo "=========================================="
