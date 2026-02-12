# GCP 스크립트 - Cloud SQL 모듈

#gcp #스크립트 #cloudsql #mysql

---

Cloud SQL (MySQL 8.0) 인스턴스를 Private IP로 구축하는 모듈이다. VPC 피어링을 통해 내부 네트워크에서만 접근 가능.

> 관련 문서: [[GCP_Infra_MOC]] | [[gcp-script-env]] | [[gcp-cloud-sql]] | [[gcp-cloud-sql-connect]]

## 파일

| 파일 | 용도 |
|------|------|
| `gcp-cloudsql-setup.sh` | Cloud SQL (Private IP) + DB + 사용자 생성 |
| `gcp-cloudsql-cleanup.sh` | Cloud SQL + Private Service Access 삭제 |

---

## 생성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| Private Service Access | `google-managed-services-pista-vpc` | VPC 피어링 (Google 관리형 서비스용) |
| Cloud SQL 인스턴스 | `pista-mysql` | MySQL 8.0, Private IP, db-n1-standard-1 |
| 데이터베이스 | `pista-appdb` | utf8mb4 / utf8mb4_unicode_ci |
| 사용자 | `pista-user` | 원격 접속 허용 (host: %) |

---

## 실행

```bash
bash gcp-cloudsql-setup.sh    # 약 10분 소요
```

---

## 연결 방법

```bash
# 1) VPC 내부 VM에서 직접 연결
mysql -h <PRIVATE_IP> -u pista-user -pAppUser456! pista-appdb

# 2) 로컬에서 Cloud SQL Auth Proxy 사용
./cloud-sql-proxy <CONNECTION_NAME> --port=3306
mysql -h 127.0.0.1 -u pista-user -pAppUser456! pista-appdb
```

---

## 정리

```bash
bash gcp-cloudsql-cleanup.sh
```

> Cleanup 시 IP 범위(`google-managed-services-*`) 삭제로 VPC 피어링도 함께 정리된다.
