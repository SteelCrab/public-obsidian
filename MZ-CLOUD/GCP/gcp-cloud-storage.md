# GCP Cloud Storage

#gcp #storage #버킷 #오브젝트

---

GCP의 오브젝트 스토리지 서비스. AWS S3에 대응하는 서비스로, 비정형 데이터(이미지, 동영상, 로그, 백업 등)를 저장한다.

## 1. Cloud Storage 개요

### 특징
| **항목** | **설명** |
|---------|---------|
| **서비스 유형** | 완전 관리형 오브젝트 스토리지 |
| **내구성** | 99.999999999% (11 nines) |
| **가용성** | Standard: 99.95% (Multi-Region), 99.9% (Region) |
| **최대 객체 크기** | 5TB (단일 객체) |
| **버킷 이름** | 전 세계적으로 고유해야 함 |
| **접근 제어** | IAM + ACL (Uniform / Fine-grained) |
| **암호화** | 서버 측 자동 암호화 (Google-managed / CMEK / CSEK) |
| **버전 관리** | 객체 버전 관리 지원 |

### AWS S3 vs Cloud Storage 비교
| **항목** | **AWS S3** | **Cloud Storage** |
|---------|-----------|-------------------|
| **스토리지 클래스** | Standard, IA, One Zone-IA, Glacier, Deep Archive | Standard, Nearline, Coldline, Archive |
| **버킷 범위** | 리전별 | 리전, 듀얼 리전, 멀티 리전 |
| **접근 제어** | 버킷 정책 + ACL | IAM + ACL (Uniform 권장) |
| **정적 웹 호스팅** | S3 Static Website | Cloud Storage + Load Balancer |
| **수명 주기** | Lifecycle Rules | Lifecycle Management |
| **전송 가속** | Transfer Acceleration | CDN Interconnect |
| **이벤트 알림** | S3 Event Notifications → Lambda/SNS/SQS | Pub/Sub Notifications / Eventarc |
| **CLI** | `aws s3` / `aws s3api` | `gcloud storage` / `gsutil` |

---

## 2. 스토리지 클래스

| **클래스**      | **용도**               | **최소 보관 기간** | **가용성 SLA**                    | **비용 (GB/월)** |
| ------------ | -------------------- | ------------ | ------------------------------ | ------------- |
| **Standard** | 자주 접근하는 데이터 (핫 데이터)  | 없음           | 99.95% (Multi), 99.9% (Region) | 가장 비쌈         |
| **Nearline** | 월 1회 미만 접근           | 30일          | 99.9% (Multi), 99.0% (Region)  | 중간            |
| **Coldline** | 분기 1회 미만 접근          | 90일          | 99.9% (Multi), 99.0% (Region)  | 저렴            |
| **Archive**  | 연 1회 미만 접근 (백업/아카이브) | 365일         | 99.9% (Multi), 99.0% (Region)  | 가장 저렴         |

> 최소 보관 기간 이전에 삭제하면 조기 삭제 요금이 부과된다.

---

**관련 문서**: [[gcp-storage-bucket]] | [[gcp-storage-object]] | [[gcp-storage-iam]] | [[gcp-storage-lifecycle]] | [[gcp-storage-event]] | [[gcp-storage-web]] | [[GCP_MOC]]
