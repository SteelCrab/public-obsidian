# GCP Cloud SQL

#gcp #cloudsql #데이터베이스 #mysql #postgresql

---

GCP의 완전 관리형 관계형 데이터베이스 서비스인 Cloud SQL의 개요, 인스턴스 생성, 데이터베이스 및 사용자 관리 방법을 정리한다.

관련 문서: [[gcp-cloud-sql-connect]] | [[gcp-cloud-sql-ha]] | [[gcp-cloud-sql-ops]] | [[gcp-vpc]]

## 1. Cloud SQL 개요

### Cloud SQL 특징
| **항목** | **설명** |
|---------|---------|
| **서비스 유형** | 완전 관리형 관계형 데이터베이스 서비스 |
| **지원 DB 엔진** | MySQL, PostgreSQL, SQL Server |
| **자동 백업** | 일일 자동 백업 + 트랜잭션 로그 백업 |
| **고가용성** | 리전 내 자동 장애 조치 (Regional HA) |
| **자동 패치** | Google이 DB 엔진 패치 및 OS 업데이트 관리 |
| **암호화** | 저장 데이터 및 전송 데이터 자동 암호화 |
| **확장성** | 수직 확장 (머신 타입 변경) + 읽기 전용 복제본 |
| **최대 스토리지** | 64TB (MySQL/PostgreSQL) |
| **SLA** | 99.95% (HA 구성 시) |

### VM MySQL vs Cloud SQL 비교
| **항목** | **VM에 직접 설치** | **Cloud SQL** |
|---------|------------------|--------------|
| **설치/설정** | 수동 (apt install, my.cnf 설정) | gcloud 명령어 한 줄로 생성 |
| **백업** | 수동 (mysqldump, cron 설정) | 자동 백업 + 온디맨드 백업 |
| **패치/업데이트** | 수동 (apt upgrade) | Google이 자동 관리 |
| **HA/장애 조치** | 수동 구성 (Replication + Failover) | 체크박스 하나로 HA 활성화 |
| **모니터링** | 수동 (Prometheus, Grafana 등) | Cloud Monitoring 자동 통합 |
| **보안** | 수동 (SSL 설정, 방화벽 관리) | 자동 암호화, IAM 통합 |
| **비용** | VM 비용만 (저렴하지만 관리 비용 높음) | 관리형 서비스 비용 (높지만 운영 비용 절감) |
| **적합한 경우** | 세밀한 제어 필요, 비용 최소화 | 운영 부담 최소화, 프로덕션 환경 |

### AWS RDS vs Cloud SQL 비교
| **항목** | **AWS RDS** | **Cloud SQL** |
|---------|------------|--------------|
| **지원 엔진** | MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, Aurora | MySQL, PostgreSQL, SQL Server |
| **HA 방식** | Multi-AZ (다른 AZ에 스탠바이) | Regional HA (같은 리전 내 다른 존) |
| **읽기 복제본** | 리전 내 + 크로스 리전 | 리전 내 + 크로스 리전 |
| **자동 백업** | 최대 35일 보관 | 최대 365일 보관 |
| **연결 프록시** | RDS Proxy | Cloud SQL Auth Proxy |
| **Private 연결** | VPC 내 서브넷 그룹 | VPC 피어링 또는 Private Service Connect |
| **서버리스 옵션** | Aurora Serverless | Cloud SQL 없음 (AlloyDB 또는 Spanner 사용) |

---

## 2. Cloud SQL 인스턴스 생성

### MySQL 인스턴스 생성
```bash
# MySQL 8.0 인스턴스 생성 (기본)
gcloud sql instances create my-mysql \
    --database-version=MYSQL_8_0 \
    --tier=db-n1-standard-2 \
    --region=asia-northeast1 \
    --storage-size=20GB \
    --storage-type=SSD \
    --storage-auto-increase

# MySQL 인스턴스 생성 (상세 옵션)
gcloud sql instances create my-mysql \
    --database-version=MYSQL_8_0 \
    --tier=db-custom-4-16384 \
    --region=asia-northeast1 \
    --storage-size=50GB \
    --storage-type=SSD \
    --storage-auto-increase \
    --backup-start-time=03:00 \
    --enable-bin-log \
    --maintenance-window-day=SUN \
    --maintenance-window-hour=2 \
    --availability-type=REGIONAL \
    --root-password=<ROOT_PASSWORD>
```

### PostgreSQL 인스턴스 생성
```bash
# PostgreSQL 15 인스턴스 생성
gcloud sql instances create my-postgres \
    --database-version=POSTGRES_15 \
    --tier=db-custom-4-16384 \
    --region=asia-northeast1 \
    --storage-size=50GB \
    --storage-type=SSD \
    --storage-auto-increase \
    --backup-start-time=03:00 \
    --availability-type=REGIONAL
```

### 인스턴스 생성 옵션
| **옵션** | **설명** | **값** |
|---------|---------|--------|
| `--database-version` | DB 엔진 버전 | `MYSQL_8_0`, `MYSQL_5_7`, `POSTGRES_15`, `POSTGRES_14`, `SQLSERVER_2019_STANDARD` |
| `--tier` | 머신 타입 | `db-n1-standard-1`, `db-custom-<CPU>-<RAM_MB>` |
| `--region` | 리전 | `asia-northeast1` (도쿄) |
| `--storage-size` | 스토리지 크기 | `10GB` ~ `64TB` |
| `--storage-type` | 스토리지 유형 | `SSD` (기본), `HDD` |
| `--storage-auto-increase` | 스토리지 자동 확장 | 플래그 설정 |
| `--storage-auto-increase-limit` | 자동 확장 최대 크기 | `0` (무제한), 또는 GB 단위 |
| `--backup-start-time` | 자동 백업 시작 시간 (UTC) | `03:00` (한국시간 12:00) |
| `--enable-bin-log` | 바이너리 로그 활성화 (MySQL PITR용) | 플래그 설정 |
| `--availability-type` | 가용성 타입 | `ZONAL` (단일 존), `REGIONAL` (HA) |
| `--root-password` | 루트 비밀번호 | 비밀번호 문자열 |
| `--maintenance-window-day` | 유지보수 요일 | `MON`~`SUN` |
| `--maintenance-window-hour` | 유지보수 시간 (UTC) | `0`~`23` |

### 웹 콘솔

> 📍 SQL > 인스턴스 만들기 > MySQL (또는 PostgreSQL) 선택

1. **인스턴스 ID**: `my-mysql` 입력
2. **비밀번호**: 루트 비밀번호 입력
3. **데이터베이스 버전**: `MySQL 8.0` 선택
4. **Cloud SQL 버전 선택**: `Enterprise` 선택
5. **리전 및 영역 선택**:
   - **리전**: `asia-northeast1 (도쿄)` 선택
   - **영역 가용성**: `단일 영역` 또는 `여러 영역 (고가용성)` 선택
6. **머신 구성**:
   - **머신 유형**: `경량`, `표준`, `고성능 메모리` 중 선택
   - vCPU / 메모리 조정
7. **스토리지**:
   - **스토리지 유형**: `SSD` 선택
   - **스토리지 용량**: `20` GB 입력
   - **스토리지 자동 증가 사용**: 체크
8. **연결**:
   - **공개 IP**: 체크 (기본)
   - **비공개 IP**: 필요 시 체크 > VPC 네트워크 선택
9. **데이터 보호**:
   - **자동 백업**: 체크
   - **시점 복구 사용**: 체크 (바이너리 로그)
10. **유지보수**: 기본 요일/시간 선택
11. **인스턴스 만들기** 클릭

### Private IP로 인스턴스 생성 (VPC 피어링)
```bash
# 1. Private Service Access 설정 (최초 1회)
# IP 범위 할당
gcloud compute addresses create google-managed-services \
    --global \
    --purpose=VPC_PEERING \
    --prefix-length=16 \
    --network=pista-vpc

# VPC 피어링 생성
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services \
    --network=pista-vpc

# 2. Private IP로 Cloud SQL 인스턴스 생성
gcloud sql instances create my-mysql-private \
    --database-version=MYSQL_8_0 \
    --tier=db-n1-standard-2 \
    --region=asia-northeast1 \
    --network=pista-vpc \
    --no-assign-ip \
    --storage-size=20GB \
    --storage-type=SSD
```

### Private IP - 웹 콘솔

> 📍 SQL > 인스턴스 만들기

1. 기본 설정 (위와 동일) 진행
2. **연결** 섹션:
   - **비공개 IP**: 체크
   - **네트워크**: `pista-vpc` 선택
   - **비공개 서비스 액세스 연결이 필요합니다** 안내가 나오면 **연결 설정** 클릭
   - **IP 범위 할당**: `자동으로 할당된 IP 범위 사용` 선택
   - **연결** 클릭 (VPC 피어링 생성)
   - **공개 IP**: 체크 해제 (Private만 사용 시)
3. **인스턴스 만들기** 클릭

---

## 3. 데이터베이스 및 사용자 관리

### 데이터베이스 관리
```bash
# 데이터베이스 생성
gcloud sql databases create mydb \
    --instance=my-mysql \
    --charset=utf8mb4 \
    --collation=utf8mb4_unicode_ci

# 데이터베이스 목록
gcloud sql databases list --instance=my-mysql

# 데이터베이스 삭제
gcloud sql databases delete mydb --instance=my-mysql
```

### 데이터베이스 관리 - 웹 콘솔

> 📍 SQL > my-mysql > 데이터베이스

1. **데이터베이스 만들기** 클릭
2. **데이터베이스 이름**: `mydb` 입력
3. **문자 집합**: `utf8mb4` 선택
4. **데이터 정렬**: `utf8mb4_unicode_ci` 선택
5. **만들기** 클릭

### 사용자 관리
```bash
# 사용자 생성
gcloud sql users create myuser \
    --instance=my-mysql \
    --password=<PASSWORD> \
    --host=%

# 사용자 목록
gcloud sql users list --instance=my-mysql

# 비밀번호 변경
gcloud sql users set-password myuser \
    --instance=my-mysql \
    --password=<NEW_PASSWORD> \
    --host=%

# 사용자 삭제
gcloud sql users delete myuser \
    --instance=my-mysql \
    --host=%
```

### 사용자 관리 - 웹 콘솔

> 📍 SQL > my-mysql > 사용자

1. **사용자 계정 추가** 클릭
2. **사용자 이름**: `myuser` 입력
3. **비밀번호**: 비밀번호 입력
4. **호스트 이름**: `모든 호스트 허용(%)` 선택
5. **추가** 클릭

**비밀번호 변경:**
1. 사용자 목록에서 대상 사용자의 ⋮ (더보기) 클릭
2. **비밀번호 변경** 선택
3. 새 비밀번호 입력 > **확인** 클릭
