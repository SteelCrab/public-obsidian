# GCP Cloud NAT 및 인터넷 게이트웨이

#gcp #nat #라우터 #인터넷게이트웨이

---

GCP의 Cloud NAT 구축과 인터넷 게이트웨이(IGW) 개념을 정리한다.

> 관련 문서: [[gcp-vpc]], [[gcp-firewall]]

## 1. Cloud NAT 구축

### Cloud NAT 특징

| **항목** | **설명** |
|---------|---------|
| **용도** | 외부 IP 없는 VM이 인터넷에 아웃바운드 연결 가능 |
| **관리형 서비스** | Google이 자동으로 관리 (인스턴스 불필요) |
| **고가용성** | 자동으로 중복성 제공 |
| **요금** | NAT Gateway 시간당 요금 + 데이터 처리량 요금 |

### Cloud Router 생성 (NAT 사전 요구사항)
shell
```bash
# Cloud Router 생성
gcloud compute routers create pista-router \
    --network=pista-vpc \
    --region=asia-northeast1

# Router 목록 확인
gcloud compute routers list
```

### Cloud Router 웹 콘솔

> 📍 하이브리드 연결 > Cloud Router > 라우터 만들기

1. **이름**: `pista-router` 입력
2. **네트워크**: `pista-vpc` 선택
3. **리전**: `asia-northeast1` 선택
4. **만들기** 클릭

### Cloud NAT 생성 명령어

```bash
# Cloud NAT 생성
gcloud compute routers nats create pista-nat \
    --router=pista-router \
    --region=asia-northeast1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

# NAT 상세 설정 (특정 서브넷만)
gcloud compute routers nats create pista-nat \
    --router=pista-router \
    --region=asia-northeast1 \
    --nat-custom-subnet-ip-ranges=private-subnet \
    --auto-allocate-nat-external-ips

# NAT 목록 확인
gcloud compute routers nats list --router=pista-router \
    --region=asia-northeast1
```

### Cloud NAT 웹 콘솔

> 📍 네트워크 서비스 > Cloud NAT > NAT 게이트웨이 만들기

1. **게이트웨이 이름**: `pista-nat` 입력
2. **NAT 유형**: `공개` 선택
3. **Cloud Router 선택**: `pista-router` 선택 (또는 새 라우터 만들기)
4. **소스 (내부)**: `모든 서브넷의 모든 기본 IP 범위` 선택
5. **NAT IP 주소**: `자동` 선택
6. **만들기** 클릭

### Cloud NAT 옵션

| **옵션**                             | **설명**          | **값**          |
| ---------------------------------- | --------------- | -------------- |
| `--router`                         | Cloud Router 이름 | `pista-router` |
| `--nat-all-subnet-ip-ranges`       | 모든 서브넷에 NAT 적용  | 플래그 설정         |
| `--nat-custom-subnet-ip-ranges`    | 특정 서브넷만 NAT 적용  | 서브넷 이름 지정      |
| `--auto-allocate-nat-external-ips` | 외부 IP 자동 할당     | 플래그 설정         |
| `--nat-external-ip-pool`           | 수동으로 예약된 IP 사용  | IP 주소 지정       |

---

## 2. 인터넷 게이트웨이 (IGW) 이해

### GCP IGW의 차이점 (AWS vs GCP)

| **항목** | **AWS** | **GCP** |
|---------|---------|---------|
| **IGW 리소스** | 명시적으로 생성 및 연결 필요 | **암시적 제공** (별도 생성 불필요) |
| **외부 연결** | IGW를 VPC에 연결해야 함 | 외부 IP가 있으면 자동으로 인터넷 연결 |
| **라우팅** | 라우팅 테이블에 IGW 경로 추가 | 기본 인터넷 게이트웨이 경로 자동 생성 |

### GCP에서 인터넷 연결 방법

**방법 1: 외부 IP 사용 (IGW 역할)**

```bash
# VM 생성 시 외부 IP 할당
gcloud compute instances create web-server \
    --zone=asia-northeast1-a \
    --subnet=pista-subnet-seoul \
    --network-tier=PREMIUM

# 기존 VM에 외부 IP 추가
gcloud compute instances add-access-config web-server \
    --zone=asia-northeast1-a
```

**웹 콘솔**: 📍 Compute Engine > VM 인스턴스 > 인스턴스 선택 > 수정 > 네트워크 인터페이스 > **외부 IPv4 주소**: `임시` 또는 고정 IP 선택

**방법 2: Cloud NAT 사용 (Private IP만 사용)**

```bash
# 외부 IP 없이 VM 생성
gcloud compute instances create private-server \
    --zone=asia-northeast1-a \
    --subnet=private-subnet \
    --no-address

# Cloud NAT를 통해 아웃바운드 인터넷 연결
```

**웹 콘솔**: Cloud NAT가 구성되어 있으면 `--no-address` VM도 자동으로 아웃바운드 인터넷 연결 가능 (추가 설정 불필요)

### 기본 라우팅 확인

```bash
# VPC 라우팅 테이블 확인
gcloud compute routes list --filter="network=pista-vpc"

# 기본 인터넷 게이트웨이 경로 (자동 생성됨)
# NAME: default-route-xxxx
# DEST_RANGE: 0.0.0.0/0
# NEXT_HOP: default-internet-gateway
```
