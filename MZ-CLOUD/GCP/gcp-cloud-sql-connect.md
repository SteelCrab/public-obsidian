# GCP Cloud SQL 연결 방법

#gcp #cloudsql #연결 #프록시

---

Cloud SQL 인스턴스에 연결하는 다양한 방법을 정리한다. Cloud SQL Auth Proxy, Private IP, Public IP + 승인된 네트워크 방식을 비교한다.

관련 문서: [[gcp-cloud-sql]] | [[gcp-vpc]]

## Cloud SQL Auth Proxy (권장)

```bash
# 1. Cloud SQL Auth Proxy 설치 (macOS)
curl -o cloud-sql-proxy \
    https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.1/cloud-sql-proxy.darwin.amd64
chmod +x cloud-sql-proxy

# 1. Cloud SQL Auth Proxy 설치 (Linux)
curl -o cloud-sql-proxy \
    https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.1/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy

# 2. Proxy 실행 (인스턴스 연결 이름 사용)
./cloud-sql-proxy <PROJECT_ID>:asia-northeast1:my-mysql \
    --port=3306

# 3. 다른 터미널에서 MySQL 접속
mysql -u myuser -p --host=127.0.0.1 --port=3306

# 인스턴스 연결 이름 확인
gcloud sql instances describe my-mysql \
    --format="value(connectionName)"
```

### Auth Proxy - 웹 콘솔 확인

> 📍 SQL > my-mysql > 개요

1. **이 인스턴스에 연결** 섹션에서 **연결 이름** 복사
   - 형식: `<PROJECT_ID>:asia-northeast1:my-mysql`
2. Cloud SQL Auth Proxy는 CLI 도구이므로 로컬에서 실행
3. 콘솔에서는 **Cloud Shell**을 통해 연결 가능:
   - **개요** 페이지 > **Cloud Shell을 사용하여 연결** 클릭

---

## Private IP 연결 (같은 VPC 내 VM에서)

```bash
# VM에서 Cloud SQL Private IP로 직접 연결
# (Cloud SQL이 Private IP로 생성된 경우)

# Private IP 확인
gcloud sql instances describe my-mysql-private \
    --format="value(ipAddresses.ipAddress)"

# VM에서 MySQL 접속
mysql -u myuser -p --host=<PRIVATE_IP> --port=3306
```

---

## Public IP + 승인된 네트워크

```bash
# 승인된 네트워크 추가 (특정 IP에서만 접속 허용)
gcloud sql instances patch my-mysql \
    --authorized-networks=203.0.113.0/24,198.51.100.0/32

# Public IP 확인
gcloud sql instances describe my-mysql \
    --format="value(ipAddresses[0].ipAddress)"

# 외부에서 MySQL 접속
mysql -u myuser -p --host=<PUBLIC_IP> --port=3306
```

### 승인된 네트워크 - 웹 콘솔

> 📍 SQL > my-mysql > 연결 > 네트워킹

1. **승인된 네트워크** 섹션에서 **네트워크 추가** 클릭
2. **이름**: `my-office` 입력 (설명용)
3. **네트워크**: `203.0.113.0/24` 입력
4. **완료** 클릭
5. **저장** 클릭

---

## 연결 방법 비교

| **방법** | **보안** | **설정 난이도** | **지연시간** | **적합한 경우** |
|---------|---------|--------------|-----------|--------------|
| **Cloud SQL Auth Proxy** | 높음 (IAM 인증, SSL 자동) | 중간 | 약간 추가 | 개발/운영 범용 (권장) |
| **Private IP** | 높음 (VPC 내부 통신) | 높음 (VPC 피어링 필요) | 최소 | 프로덕션 (같은 VPC 내 VM/GKE) |
| **Public IP + 승인 네트워크** | 중간 (IP 화이트리스트) | 낮음 | 중간 | 개발/테스트 (임시 접속) |
