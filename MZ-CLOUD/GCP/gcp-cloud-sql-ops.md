# GCP Cloud SQL 운영 관리

#gcp #cloudsql #운영 #유지보수

---

Cloud SQL 인스턴스의 운영 관리 명령어와 전체 구축 스크립트를 정리한다.

관련 문서: [[gcp-cloud-sql]] | [[gcp-cloud-sql-ha]] | [[gcp-vpc]]

## 1. 인스턴스 관리 명령어

```bash
# 인스턴스 목록
gcloud sql instances list

# 인스턴스 상세 정보
gcloud sql instances describe my-mysql

# 인스턴스 재시작
gcloud sql instances restart my-mysql

# 인스턴스 삭제 (삭제 보호가 없으면 즉시 삭제)
gcloud sql instances delete my-mysql
```

---

## 2. 머신 타입 변경

```bash
# 머신 타입 변경 (다운타임 발생)
gcloud sql instances patch my-mysql \
    --tier=db-n1-standard-4

# 커스텀 머신 타입 (vCPU 4개, RAM 16GB)
gcloud sql instances patch my-mysql \
    --tier=db-custom-4-16384
```

---

## 3. 스토리지 확장

```bash
# 스토리지 크기 확장 (축소 불가)
gcloud sql instances patch my-mysql \
    --storage-size=100GB

# 스토리지 자동 확장 활성화
gcloud sql instances patch my-mysql \
    --storage-auto-increase \
    --storage-auto-increase-limit=500GB
```

---

## 4. 유지보수 윈도우 설정

```bash
# 유지보수 윈도우 설정 (UTC 기준)
gcloud sql instances patch my-mysql \
    --maintenance-window-day=SUN \
    --maintenance-window-hour=2

# 유지보수 거부 기간 설정 (특정 기간 유지보수 차단)
gcloud sql instances patch my-mysql \
    --deny-maintenance-period-start-date=2026-12-20 \
    --deny-maintenance-period-end-date=2026-12-31 \
    --deny-maintenance-period-time=00:00:00
```

---

## 5. 데이터베이스 플래그 설정

```bash
# MySQL 플래그 설정
gcloud sql instances patch my-mysql \
    --database-flags=character_set_server=utf8mb4,\
max_connections=500,\
slow_query_log=on,\
long_query_time=2,\
innodb_buffer_pool_size=4294967296

# 현재 플래그 확인
gcloud sql instances describe my-mysql \
    --format="value(settings.databaseFlags)"

# 플래그 초기화 (모든 플래그 기본값으로)
gcloud sql instances patch my-mysql \
    --clear-database-flags
```

---

## 6. Cloud SQL 전체 구축 스크립트

Private IP + HA 구성의 Cloud SQL 인스턴스를 VM과 연동하여 구축하는 전체 스크립트이다.

```bash
#!/bin/bash
# Cloud SQL (Private IP) + VM 연동 구축 스크립트

PROJECT_ID="named-foundry-486921-r5"
REGION="asia-northeast1"
ZONE="asia-northeast1-a"
VPC_NAME="pista-vpc"
INSTANCE_NAME="pista-mysql"

# 프로젝트 설정
gcloud config set project $PROJECT_ID

# 1. 필요한 API 활성화
echo "[1/7] API 활성화..."
gcloud services enable sqladmin.googleapis.com
gcloud services enable servicenetworking.googleapis.com

# 2. Private Service Access 설정 (VPC 피어링)
echo "[2/7] Private Service Access 설정..."
gcloud compute addresses create google-managed-services \
    --global \
    --purpose=VPC_PEERING \
    --prefix-length=16 \
    --network=$VPC_NAME

gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services \
    --network=$VPC_NAME

# 3. Cloud SQL 인스턴스 생성 (Private IP, HA)
echo "[3/7] Cloud SQL 인스턴스 생성..."
gcloud sql instances create $INSTANCE_NAME \
    --database-version=MYSQL_8_0 \
    --tier=db-custom-2-8192 \
    --region=$REGION \
    --network=$VPC_NAME \
    --no-assign-ip \
    --storage-size=20GB \
    --storage-type=SSD \
    --storage-auto-increase \
    --availability-type=REGIONAL \
    --backup-start-time=18:00 \
    --enable-bin-log \
    --maintenance-window-day=SUN \
    --maintenance-window-hour=17 \
    --database-flags=character_set_server=utf8mb4,max_connections=200 \
    --root-password=ChangeMe123!

# 4. 데이터베이스 생성
echo "[4/7] 데이터베이스 생성..."
gcloud sql databases create appdb \
    --instance=$INSTANCE_NAME \
    --charset=utf8mb4 \
    --collation=utf8mb4_unicode_ci

# 5. 애플리케이션 사용자 생성
echo "[5/7] 사용자 생성..."
gcloud sql users create appuser \
    --instance=$INSTANCE_NAME \
    --password=AppUserPass123! \
    --host=%

# 6. 읽기 전용 복제본 생성
echo "[6/7] 읽기 전용 복제본 생성..."
gcloud sql instances create ${INSTANCE_NAME}-read1 \
    --master-instance-name=$INSTANCE_NAME \
    --region=$REGION \
    --tier=db-custom-2-8192 \
    --storage-size=20GB

# 7. 상태 확인
echo "[7/7] 구축 완료! 상태 확인..."
PRIVATE_IP=$(gcloud sql instances describe $INSTANCE_NAME \
    --format="value(ipAddresses[0].ipAddress)")

echo ""
echo "========================================="
echo " Cloud SQL 구축 완료"
echo "========================================="
echo " 인스턴스: $INSTANCE_NAME"
echo " Private IP: $PRIVATE_IP"
echo " 데이터베이스: appdb"
echo " 사용자: appuser"
echo " 복제본: ${INSTANCE_NAME}-read1"
echo "========================================="
echo ""
echo "# VM에서 접속 테스트:"
echo "mysql -u appuser -p --host=$PRIVATE_IP appdb"
```
