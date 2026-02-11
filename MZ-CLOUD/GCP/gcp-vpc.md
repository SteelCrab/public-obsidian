# GCP VPC 및 서브넷

#gcp #vpc #서브넷 #네트워크

---

GCP의 VPC(Virtual Private Cloud)와 서브넷 구축 방법을 정리한다.

> 관련 문서: [[gcp-cloud-nat]], [[gcp-firewall]], [[gcp-cli]]

## 1. VPC (Virtual Private Cloud) 구축

### VPC 특징

| **항목** | **설명** |
|---------|---------|
| **범위** | 글로벌 리소스 (모든 리전에서 사용 가능) |
| **서브넷** | 리전별로 생성 (여러 존에 걸쳐 있음) |
| **라우팅** | 자동 라우팅 테이블 생성 및 관리 |
| **방화벽** | VPC 레벨에서 방화벽 규칙 적용 |

### CLI (gcloud)

```bash
# VPC 생성 (자동 모드)
gcloud compute networks create pista-vpc \
    --subnet-mode=auto \
    --bgp-routing-mode=regional \
    --mtu=1460

# VPC 생성 (커스텀 모드 - 서브넷 수동 생성)
gcloud compute networks create pista-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# VPC 목록 확인
gcloud compute networks list

# VPC 상세 정보 확인
gcloud compute networks describe pista-vpc
```

### 웹 콘솔

> 📍 VPC 네트워크 > VPC 네트워크 만들기

1. **이름**: `pista-vpc` 입력
2. **설명**: 선택 사항
3. **서브넷 생성 모드**: `커스텀` 선택 (수동 서브넷 관리)
4. **MTU**: `1460` (기본값)
5. **동적 라우팅 모드**: `리전` 선택
6. **만들기** 클릭

### VPC 생성 옵션

| **옵션** | **설명** | **값** |
|---------|---------|--------|
| `--subnet-mode` | 서브넷 생성 모드 | `auto` (자동), `custom` (수동) |
| `--bgp-routing-mode` | 동적 라우팅 모드 | `regional` (리전별), `global` (글로벌) |
| `--mtu` | 최대 전송 단위 | `1460` (기본), `1500` (점보 프레임) |

---

## 2. 서브넷 (Subnet) 구축

### 서브넷 특징

- **리전 리소스**: 특정 리전에 속하며, 해당 리전의 모든 존에서 사용 가능
- **IP 범위**: RFC 1918 사설 IP 대역 사용 (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- **자동 확장**: 서브넷 IP 범위를 나중에 확장 가능

### CLI (gcloud)

```bash
# 서브넷 생성
gcloud compute networks subnets create pista-subnet-seoul \
    --network=pista-vpc \
    --region=asia-northeast1 \
    --range=10.0.0.0/24 \
    --enable-private-ip-google-access \
    --enable-flow-logs

# 서브넷 목록 확인
gcloud compute networks subnets list --network=pista-vpc

# 서브넷 상세 정보
gcloud compute networks subnets describe pista-subnet-seoul \
    --region=asia-northeast1
```

### 웹 콘솔

> 📍 VPC 네트워크 > VPC 네트워크 > pista-vpc > 서브넷 > 서브넷 추가

1. **이름**: `pista-subnet-seoul` 입력
2. **리전**: `asia-northeast1 (도쿄)` 선택
3. **IP 스택 유형**: `IPv4(단일 스택)` 선택
4. **IPv4 범위**: `10.0.0.0/24` 입력
5. **비공개 Google 액세스**: `사용` 선택
6. **흐름 로그**: 필요 시 `사용` 선택
7. **추가** 클릭

### 서브넷 생성 옵션

| **옵션**                              | **설명**         | **권장값**                    |
| ----------------------------------- | -------------- | -------------------------- |
| `--network`                         | VPC 네트워크 이름    | `pista-vpc`                |
| `--region`                          | 리전             | `asia-northeast1` (도쿄)     |
| `--range`                           | IP CIDR 범위     | `10.0.0.0/24`              |
| `--enable-private-ip-google-access` | 비공개 Google 액세스 | 활성화 (내부 IP로 Google API 접근) |
| `--enable-flow-logs`                | VPC 흐름 로그      | 필요 시 활성화 (디버깅 용도)          |

### 여러 서브넷 구성 예시

```bash
# Public 서브넷 (웹 서버용)
gcloud compute networks subnets create public-subnet \
    --network=pista-vpc \
    --region=asia-northeast3 \
    --range=10.0.1.0/24

# Private 서브넷 (DB용)
gcloud compute networks subnets create private-subnet \
    --network=pista-vpc \
    --region=asia-northeast3 \
    --range=10.0.2.0/24 \
    --enable-private-ip-google-access
```
