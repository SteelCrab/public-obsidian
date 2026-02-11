# GCP Cloud SQL 고가용성 및 백업

#gcp #cloudsql #고가용성 #백업 #복제본

---

Cloud SQL의 백업/복원, 고가용성(HA), 읽기 전용 복제본 구성 방법을 정리한다.

관련 문서: [[gcp-cloud-sql]] | [[gcp-cloud-sql-ops]]

## 1. 백업 및 복원

### 자동 백업 설정
```bash
# 자동 백업 활성화 (UTC 기준 시간 설정)
gcloud sql instances patch my-mysql \
    --backup-start-time=03:00

# 자동 백업 보관 기간 설정
gcloud sql instances patch my-mysql \
    --retained-backups-count=30 \
    --enable-bin-log

# 자동 백업 비활성화
gcloud sql instances patch my-mysql \
    --no-backup
```

### 수동 백업 (온디맨드)
```bash
# 수동 백업 생성
gcloud sql backups create \
    --instance=my-mysql \
    --description="배포 전 수동 백업"

# 백업 목록 확인
gcloud sql backups list --instance=my-mysql

# 백업 상세 정보
gcloud sql backups describe <BACKUP_ID> \
    --instance=my-mysql
```

### 백업에서 복원
```bash
# 같은 인스턴스로 복원 (기존 데이터 덮어쓰기)
gcloud sql backups restore <BACKUP_ID> \
    --restore-instance=my-mysql

# 다른 인스턴스로 복원 (새 인스턴스 생성)
gcloud sql instances clone my-mysql my-mysql-restored \
    --point-in-time=<BACKUP_TIMESTAMP>
```

### PITR (Point-in-Time Recovery)
```bash
# 바이너리 로그 활성화 (PITR 전제 조건)
gcloud sql instances patch my-mysql \
    --enable-bin-log

# 특정 시점으로 복원 (새 인스턴스로 클론)
gcloud sql instances clone my-mysql my-mysql-pitr \
    --point-in-time="2026-02-10T03:00:00.000Z"
```

---

## 2. 고가용성 (HA)

### HA 특징
| **항목** | **설명** |
|---------|---------|
| **구성** | 프라이머리 + 스탠바이 인스턴스 (같은 리전, 다른 존) |
| **장애 감지** | 하트비트 기반 자동 감지 |
| **장애 조치 시간** | 약 60초 내외 |
| **데이터 동기화** | 동기식 복제 (데이터 손실 없음) |
| **비용** | 프라이머리 인스턴스의 약 2배 (스탠바이 비용 추가) |
| **자동 복구** | 장애 해결 후 자동으로 원래 구성 복원 |
| **SLA** | 99.95% 가용성 |

### HA 설정
```bash
# 새 인스턴스를 HA로 생성
gcloud sql instances create my-mysql-ha \
    --database-version=MYSQL_8_0 \
    --tier=db-n1-standard-4 \
    --region=asia-northeast1 \
    --availability-type=REGIONAL \
    --storage-size=50GB \
    --storage-type=SSD

# 기존 인스턴스를 HA로 변경
gcloud sql instances patch my-mysql \
    --availability-type=REGIONAL

# HA를 단일 존으로 변경 (비용 절감)
gcloud sql instances patch my-mysql \
    --availability-type=ZONAL
```

### 장애 조치 (Failover)
```bash
# 수동 장애 조치 (테스트용)
gcloud sql instances failover my-mysql-ha

# 인스턴스 상태 확인
gcloud sql instances describe my-mysql-ha \
    --format="value(state)"
```

---

## 3. 읽기 전용 복제본

### 복제본 생성 및 관리
```bash
# 읽기 전용 복제본 생성
gcloud sql instances create my-mysql-read1 \
    --master-instance-name=my-mysql \
    --region=asia-northeast1 \
    --tier=db-n1-standard-2 \
    --storage-size=20GB

# 크로스 리전 복제본 (DR용)
gcloud sql instances create my-mysql-read-us \
    --master-instance-name=my-mysql \
    --region=us-central1 \
    --tier=db-n1-standard-2

# 복제본 목록 확인
gcloud sql instances list --filter="instanceType=READ_REPLICA_INSTANCE"

# 복제본 삭제
gcloud sql instances delete my-mysql-read1
```

### 복제본을 독립 인스턴스로 승격
```bash
# 복제본 승격 (독립 인스턴스가 됨, 복제 관계 끊어짐)
gcloud sql instances promote-replica my-mysql-read1

# 승격 후 상태 확인
gcloud sql instances describe my-mysql-read1 \
    --format="value(instanceType)"
# 출력: CLOUD_SQL_INSTANCE (독립 인스턴스)
```
