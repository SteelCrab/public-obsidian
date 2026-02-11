# GCP Load Balancer

#gcp #로드밸런서 #네트워크 #트래픽

---

GCP의 완전 관리형 로드 밸런싱 서비스. 전 세계 단일 Anycast IP로 글로벌 트래픽을 분산한다.

## 1. Load Balancer 개요

### 특징
| **항목** | **설명** |
|---------|---------|
| **글로벌 LB** | 단일 Anycast IP로 전 세계 트래픽 수신 |
| **자동 확장** | 트래픽 증가 시 자동으로 확장 (워밍업 불필요) |
| **SSL/TLS** | Google 관리형 SSL 인증서 지원 |
| **헬스 체크** | 백엔드 상태를 자동으로 확인 및 제외 |
| **CDN 통합** | Cloud CDN과 원클릭 통합 |
| **IAP 통합** | Identity-Aware Proxy로 인증 연동 가능 |

### AWS vs GCP 로드 밸런서 비교
| **항목** | **AWS** | **GCP** |
|---------|---------|---------|
| **L7 (HTTP/S)** | ALB (Application Load Balancer) | HTTP(S) Load Balancer |
| **L4 (TCP/UDP)** | NLB (Network Load Balancer) | TCP/UDP Load Balancer |
| **글로벌 LB** | CloudFront + ALB 조합 | 단일 글로벌 HTTP(S) LB |
| **Anycast IP** | 미지원 (리전별 IP) | 지원 (글로벌 단일 IP) |
| **워밍업** | 트래픽 급증 시 Pre-warming 필요 | 불필요 (즉각 확장) |
| **SSL 인증서** | ACM (AWS Certificate Manager) | Google 관리형 인증서 |
| **내부 LB** | Internal ALB / NLB | Internal HTTP(S) / TCP/UDP LB |

---

## 2. Load Balancer 유형

| **유형** | **계층** | **범위** | **프로토콜** | **용도** |
|---------|---------|---------|-----------|---------|
| **외부 HTTP(S) LB** | L7 | 글로벌 | HTTP, HTTPS | 웹 애플리케이션, API (가장 많이 사용) |
| **외부 TCP/SSL Proxy LB** | L4 | 글로벌 | TCP, SSL | SSL 오프로드, 글로벌 TCP 서비스 |
| **외부 TCP/UDP 네트워크 LB** | L4 | 리전 | TCP, UDP | 게임 서버, VoIP, 비 HTTP 트래픽 |
| **내부 HTTP(S) LB** | L7 | 리전 | HTTP, HTTPS | 마이크로서비스 간 내부 통신 |
| **내부 TCP/UDP LB** | L4 | 리전 | TCP, UDP | 내부 DB, 캐시 서버 접근 |
| **내부 리전 TCP Proxy LB** | L4 | 리전 | TCP | 내부 TCP 프록시 |

---

## 3. 외부 HTTP(S) Load Balancer (글로벌 L7)

### 아키텍처 구성 요소
```
클라이언트 → 전역 외부 IP (Anycast)
             → SSL 인증서 (HTTPS 종료)
             → URL Map (경로 기반 라우팅)
             → Backend Service (백엔드 그룹)
                 → MIG / NEG / Cloud Storage 버킷
                 → Health Check (헬스 체크)
```

### 3-1. 헬스 체크 생성
```bash
gcloud compute health-checks create http web-health-check \
    --port=80 \
    --request-path=/ \
    --check-interval=10s \
    --timeout=5s \
    --unhealthy-threshold=3 \
    --healthy-threshold=2
```

### 3-2. 백엔드 서비스 생성
```bash
# 백엔드 서비스 생성
gcloud compute backend-services create web-backend-service \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=web-health-check \
    --global

# MIG를 백엔드에 추가
gcloud compute backend-services add-backend web-backend-service \
    --instance-group=web-server-mig \
    --instance-group-region=asia-northeast1 \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --global
```

### 3-3. URL Map 생성
```bash
# 기본 URL Map (모든 트래픽을 하나의 백엔드로)
gcloud compute url-maps create web-url-map \
    --default-service=web-backend-service

# 경로 기반 라우팅
gcloud compute url-maps add-path-matcher web-url-map \
    --path-matcher-name=path-matcher \
    --default-service=web-backend-service \
    --path-rules="/api/*=api-backend-service,/static/*=static-backend-service"
```

### 3-4. SSL 인증서 (HTTPS)
```bash
# Google 관리형 SSL 인증서 생성
gcloud compute ssl-certificates create my-cert \
    --domains=example.com,www.example.com \
    --global

# 인증서 목록 확인
gcloud compute ssl-certificates list

# 인증서 상태 확인 (PROVISIONING → ACTIVE)
gcloud compute ssl-certificates describe my-cert --global
```

### SSL 인증서 - 웹 콘솔

> 📍 네트워크 서비스 > 부하 분산 > 고급 메뉴 > 인증서

1. **SSL 인증서 만들기** 클릭
2. **이름**: `my-cert` 입력
3. **만들기 모드**: `Google 관리 인증서 만들기` 선택
4. **도메인**: `example.com` 입력 (여러 도메인은 쉼표로 구분)
5. **만들기** 클릭

> 인증서 상태가 `ACTIVE`가 될 때까지 DNS A 레코드가 LB IP를 가리켜야 함

### 3-5. Target Proxy 생성
```bash
# HTTP Proxy (HTTP만)
gcloud compute target-http-proxies create web-http-proxy \
    --url-map=web-url-map

# HTTPS Proxy (SSL 인증서 연결)
gcloud compute target-https-proxies create web-https-proxy \
    --url-map=web-url-map \
    --ssl-certificates=my-cert
```

### 3-6. 전역 외부 IP + Forwarding Rule
```bash
# 전역 외부 IP 예약
gcloud compute addresses create web-lb-ip \
    --ip-version=IPV4 \
    --global

# IP 확인
gcloud compute addresses describe web-lb-ip --global \
    --format="value(address)"

# HTTP Forwarding Rule (80)
gcloud compute forwarding-rules create web-http-rule \
    --address=web-lb-ip \
    --target-http-proxy=web-http-proxy \
    --ports=80 \
    --global

# HTTPS Forwarding Rule (443)
gcloud compute forwarding-rules create web-https-rule \
    --address=web-lb-ip \
    --target-https-proxy=web-https-proxy \
    --ports=443 \
    --global
```

### 외부 HTTP(S) LB - 웹 콘솔 (전체 과정)

> 📍 네트워크 서비스 > 부하 분산 > 부하 분산기 만들기

1. **HTTP(S) 부하 분산** > **구성 시작** 클릭
2. **인터넷에서 VM으로** 선택 > **계속**

**백엔드 구성:**
3. **백엔드 서비스** > **백엔드 서비스 만들기** 클릭
4. **이름**: `web-backend-service` 입력
5. **백엔드 유형**: `인스턴스 그룹` 선택
6. **새 백엔드**:
   - **인스턴스 그룹**: `web-server-mig` 선택
   - **분산 모드**: `사용률` 선택
   - **최대 사용률**: `80`% 입력
7. **상태 확인** > **상태 확인 만들기**:
   - **이름**: `web-health-check` 입력
   - **프로토콜**: `HTTP` 선택
   - **포트**: `80` 입력
   - **저장** 클릭
8. **만들기** 클릭

**호스트 및 경로 규칙:**
9. 기본 설정 유지 (단순 라우팅) 또는 경로 규칙 추가

**프런트엔드 구성:**
10. **이름**: `web-https-rule` 입력
11. **프로토콜**: `HTTPS` 선택
12. **IP 주소**: `IP 주소 만들기` > `web-lb-ip` 입력 > **예약**
13. **인증서**: `새 인증서 만들기` 클릭
    - **이름**: `my-cert` 입력
    - **Google 관리 인증서 만들기** 선택
    - **도메인**: `example.com` 입력
    - **만들기** 클릭
14. **완료** 클릭

**검토 및 완료:**
15. 설정 내용 검토 후 **만들기** 클릭

> SSL 인증서는 DNS 레코드가 올바르게 설정된 후 자동 프로비저닝 (PROVISIONING → ACTIVE)

### 3-7. HTTP → HTTPS 리다이렉트
```bash
# 리다이렉트용 URL Map 생성
gcloud compute url-maps import http-redirect-url-map \
    --source=- <<EOF
name: http-redirect-url-map
defaultUrlRedirect:
  httpsRedirect: true
  redirectResponseCode: MOVED_PERMANENTLY_DEFAULT
EOF

# HTTP Proxy에 리다이렉트 URL Map 연결
gcloud compute target-http-proxies update web-http-proxy \
    --url-map=http-redirect-url-map
```

---

## 4. Cloud Storage 백엔드 (정적 사이트)

Cloud Storage 버킷을 백엔드로 사용하여 HTTPS + 커스텀 도메인 정적 사이트를 구성한다.

```bash
# 1. 버킷 백엔드 생성
gcloud compute backend-buckets create static-backend \
    --gcs-bucket-name=www.example.com \
    --enable-cdn

# 2. URL Map 생성
gcloud compute url-maps create static-url-map \
    --default-backend-bucket=static-backend

# 3. SSL 인증서 생성
gcloud compute ssl-certificates create static-cert \
    --domains=www.example.com \
    --global

# 4. HTTPS Proxy
gcloud compute target-https-proxies create static-https-proxy \
    --url-map=static-url-map \
    --ssl-certificates=static-cert

# 5. 전역 IP + Forwarding Rule
gcloud compute addresses create static-lb-ip --ip-version=IPV4 --global

gcloud compute forwarding-rules create static-https-rule \
    --address=static-lb-ip \
    --target-https-proxy=static-https-proxy \
    --ports=443 \
    --global

# 6. DNS 설정 (Cloud DNS 또는 외부 DNS)
# www.example.com → <static-lb-ip> A 레코드 추가
```

---

## 5. 내부 HTTP(S) Load Balancer (리전 L7)

VPC 내부 마이크로서비스 간 트래픽 분산용.

```bash
# Proxy 전용 서브넷 생성 (내부 LB 필수)
gcloud compute networks subnets create proxy-only-subnet \
    --network=pista-vpc \
    --region=asia-northeast1 \
    --range=10.0.100.0/24 \
    --purpose=REGIONAL_MANAGED_PROXY \
    --role=ACTIVE

# 헬스 체크
gcloud compute health-checks create http internal-health-check \
    --port=8080 \
    --request-path=/healthz \
    --region=asia-northeast1

# 백엔드 서비스 (리전)
gcloud compute backend-services create internal-backend \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=internal-health-check \
    --health-checks-region=asia-northeast1 \
    --load-balancing-scheme=INTERNAL_MANAGED \
    --region=asia-northeast1

# MIG를 백엔드에 추가
gcloud compute backend-services add-backend internal-backend \
    --instance-group=app-server-mig \
    --instance-group-zone=asia-northeast1-a \
    --region=asia-northeast1

# URL Map
gcloud compute url-maps create internal-url-map \
    --default-service=internal-backend \
    --region=asia-northeast1

# Target Proxy
gcloud compute target-http-proxies create internal-http-proxy \
    --url-map=internal-url-map \
    --region=asia-northeast1

# Forwarding Rule (내부 IP)
gcloud compute forwarding-rules create internal-http-rule \
    --load-balancing-scheme=INTERNAL_MANAGED \
    --network=pista-vpc \
    --subnet=private-subnet \
    --target-http-proxy=internal-http-proxy \
    --target-http-proxy-region=asia-northeast1 \
    --ports=80 \
    --region=asia-northeast1
```

---

## 6. 외부 TCP/UDP 네트워크 Load Balancer (리전 L4)

```bash
# 타겟 풀 생성
gcloud compute target-pools create tcp-pool \
    --region=asia-northeast1

# 타겟 풀에 인스턴스 추가
gcloud compute target-pools add-instances tcp-pool \
    --instances=server-1,server-2 \
    --instances-zone=asia-northeast1-a \
    --region=asia-northeast1

# 리전 외부 IP 예약
gcloud compute addresses create tcp-lb-ip \
    --region=asia-northeast1

# Forwarding Rule
gcloud compute forwarding-rules create tcp-rule \
    --address=tcp-lb-ip \
    --target-pool=tcp-pool \
    --ports=8080 \
    --region=asia-northeast1
```

---

## 7. Cloud CDN 연동

```bash
# 기존 백엔드 서비스에 CDN 활성화
gcloud compute backend-services update web-backend-service \
    --enable-cdn \
    --global

# 캐시 정책 설정
gcloud compute backend-services update web-backend-service \
    --cache-mode=CACHE_ALL_STATIC \
    --default-ttl=3600 \
    --max-ttl=86400 \
    --global

# CDN 캐시 무효화 (Purge)
gcloud compute url-maps invalidate-cdn-cache web-url-map \
    --path="/*" \
    --global

# 백엔드 버킷에 CDN 활성화
gcloud compute backend-buckets update static-backend \
    --enable-cdn
```

### 캐시 모드
| **모드** | **설명** |
|---------|---------|
| `CACHE_ALL_STATIC` | 정적 콘텐츠 자동 캐시 (이미지, CSS, JS 등) |
| `USE_ORIGIN_HEADERS` | 오리진의 Cache-Control 헤더를 따름 |
| `FORCE_CACHE_ALL` | 모든 응답을 강제 캐시 |

---

## 8. 관리 명령어

```bash
# Forwarding Rule 목록
gcloud compute forwarding-rules list

# 백엔드 서비스 목록
gcloud compute backend-services list

# 백엔드 서비스 상세 (헬스 상태 포함)
gcloud compute backend-services get-health web-backend-service --global

# URL Map 목록
gcloud compute url-maps list

# SSL 인증서 목록
gcloud compute ssl-certificates list

# 헬스 체크 목록
gcloud compute health-checks list

# 전역 IP 목록
gcloud compute addresses list --global
```

### 리소스 삭제 순서
```bash
# LB 삭제는 역순으로 진행
# 1. Forwarding Rule 삭제
gcloud compute forwarding-rules delete web-https-rule --global -q

# 2. Target Proxy 삭제
gcloud compute target-https-proxies delete web-https-proxy -q

# 3. URL Map 삭제
gcloud compute url-maps delete web-url-map -q

# 4. Backend Service 삭제
gcloud compute backend-services delete web-backend-service --global -q

# 5. Health Check 삭제
gcloud compute health-checks delete web-health-check -q

# 6. SSL 인증서 삭제
gcloud compute ssl-certificates delete my-cert --global -q

# 7. 전역 IP 삭제
gcloud compute addresses delete web-lb-ip --global -q
```

---

**관련 문서**: [[gcp-vpc]] | [[gcp-firewall]] | [[gcp-instance-template]] | [[gcp-storage-web]] | [[GCP_MOC]]
