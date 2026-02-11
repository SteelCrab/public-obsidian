# GCP 방화벽 규칙

#gcp #방화벽 #보안 #네트워크

---

GCP VPC의 방화벽 규칙 설정 방법을 정리한다.

> 관련 문서: [[gcp-vpc]]

## 기본 방화벽 규칙

### CLI (gcloud)

```bash
# SSH 허용 (내부 관리용)
gcloud compute firewall-rules create allow-ssh \
    --network=pista-vpc \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow SSH from anywhere"

# HTTP/HTTPS 허용 (웹 서버용)
gcloud compute firewall-rules create allow-http-https \
    --network=pista-vpc \
    --allow=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server

# ICMP 허용 (핑 테스트용)
gcloud compute firewall-rules create allow-icmp \
    --network=pista-vpc \
    --allow=icmp \
    --source-ranges=10.0.0.0/8

# 방화벽 규칙 목록 확인
gcloud compute firewall-rules list --filter="network=pista-vpc"
```

### 웹 콘솔

> 📍 VPC 네트워크 > 방화벽 > 방화벽 규칙 만들기

**SSH 허용 규칙 생성:**

1. **이름**: `allow-ssh` 입력
2. **네트워크**: `pista-vpc` 선택
3. **트래픽 방향**: `수신` 선택
4. **일치 시 작업**: `허용` 선택
5. **대상**: `네트워크의 모든 인스턴스` 선택
6. **소스 필터**: `IPv4 범위` 선택
7. **소스 IPv4 범위**: `0.0.0.0/0` 입력
8. **프로토콜 및 포트**: `지정된 프로토콜 및 포트` > `TCP` 체크 > `22` 입력
9. **만들기** 클릭

**HTTP/HTTPS 허용 규칙 생성:**

1. **이름**: `allow-http-https` 입력
2. **네트워크**: `pista-vpc` 선택
3. **대상**: `지정된 대상 태그` 선택 > `web-server` 입력
4. **소스 IPv4 범위**: `0.0.0.0/0` 입력
5. **프로토콜 및 포트**: `TCP` 체크 > `80, 443` 입력
6. **만들기** 클릭

**ICMP 허용 규칙 생성:**

1. **이름**: `allow-icmp` 입력
2. **네트워크**: `pista-vpc` 선택
3. **소스 IPv4 범위**: `10.0.0.0/8` 입력
4. **프로토콜 및 포트**: `기타` 체크 > `icmp` 입력
5. **만들기** 클릭
