#!/bin/bash
# GCP Cloud SQL 모듈: Cloud SQL (독립 실행, VPC 필수)
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/gcp-env.sh"

banner "Cloud SQL 인스턴스 구축"

# 1. 네트워크 확인
check_network

# ==================== 2. Private Service Access 설정 ====================
step 1 5 "Private Service Access 설정 중..."

# 서비스 네트워킹 API 활성화
gcloud services enable servicenetworking.googleapis.com --quiet 2>/dev/null || true

# IP 범위 할당 (VPC 피어링용)
create_if_not_exists \
    "gcloud compute addresses describe google-managed-services-$VPC_NAME --global" \
    "gcloud compute addresses create google-managed-services-$VPC_NAME --global --purpose=VPC_PEERING --prefix-length=16 --network=$VPC_NAME" \
    "Private Service Access IP 범위"

# VPC 피어링 생성
echo "  VPC 피어링 연결 중... (최대 2분 소요)"
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services-$VPC_NAME \
    --network=$VPC_NAME 2>/dev/null || echo "  ✓ VPC 피어링이 이미 존재합니다."

# ==================== 3. Cloud SQL 인스턴스 생성 ====================
step 2 5 "Cloud SQL 인스턴스 생성 중... (최대 10분 소요)"

create_if_not_exists \
    "gcloud sql instances describe $SQL_INSTANCE" \
    "gcloud sql instances create $SQL_INSTANCE \
        --database-version=$DB_VERSION \
        --tier=$SQL_TIER \
        --region=$REGION \
        --network=$VPC_NAME \
        --no-assign-ip \
        --storage-size=20GB \
        --storage-type=SSD \
        --storage-auto-increase \
        --backup-start-time=03:00 \
        --enable-bin-log \
        --availability-type=ZONAL \
        --root-password=$ROOT_PASSWORD" \
    "Cloud SQL 인스턴스 ($SQL_INSTANCE)"

# ==================== 4. 데이터베이스 생성 ====================
step 3 5 "데이터베이스 생성 중..."

create_if_not_exists \
    "gcloud sql databases describe $DB_NAME --instance=$SQL_INSTANCE" \
    "gcloud sql databases create $DB_NAME --instance=$SQL_INSTANCE --charset=utf8mb4 --collation=utf8mb4_unicode_ci" \
    "데이터베이스 ($DB_NAME)"

# ==================== 5. 사용자 생성 ====================
step 4 5 "사용자 생성 중..."

if gcloud sql users list --instance=$SQL_INSTANCE --format="value(name)" | grep -q "^${DB_USER}$"; then
    echo "  ✓ 사용자 ($DB_USER) 이미 존재"
else
    gcloud sql users create $DB_USER \
        --instance=$SQL_INSTANCE \
        --password=$DB_USER_PASSWORD \
        --host=%
    echo "  ✓ 사용자 ($DB_USER) 생성 완료"
fi

# ==================== 6. 연결 정보 확인 ====================
step 5 5 "연결 정보 확인 중..."

SQL_PRIVATE_IP=$(gcloud sql instances describe $SQL_INSTANCE \
    --format="value(ipAddresses[0].ipAddress)")
SQL_CONNECTION_NAME=$(gcloud sql instances describe $SQL_INSTANCE \
    --format="value(connectionName)")

done_banner "Cloud SQL 구축 완료!"
echo ""
echo "인스턴스:     $SQL_INSTANCE"
echo "Private IP:  $SQL_PRIVATE_IP"
echo "연결 이름:    $SQL_CONNECTION_NAME"
echo "DB 엔진:     $DB_VERSION"
echo "데이터베이스:  $DB_NAME"
echo "사용자:       $DB_USER"
echo ""
echo "--- 연결 방법 ---"
echo ""
echo "1) VPC 내부 VM에서 직접 연결:"
echo "   mysql -h $SQL_PRIVATE_IP -u $DB_USER -p$DB_USER_PASSWORD $DB_NAME"
echo ""
echo "2) Cloud SQL Auth Proxy 사용 (로컬):"
echo "   ./cloud-sql-proxy $SQL_CONNECTION_NAME --port=3306"
echo "   mysql -h 127.0.0.1 -u $DB_USER -p$DB_USER_PASSWORD $DB_NAME"
echo ""
echo "정리: bash gcp-cloudsql-cleanup.sh"
echo "=========================================="
