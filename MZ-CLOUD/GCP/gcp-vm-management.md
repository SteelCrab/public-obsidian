# GCP VM 관리 명령어

#gcp #compute #vm관리 #네트워크

---

GCP VM의 네트워크 인터페이스, 관리 명령어, 메타데이터, 서비스 계정, 모니터링 및 로깅을 정리한 노트.

관련 문서: [[gcp-compute-engine]], [[gcp-vm-ssh]]

## 네트워크 인터페이스

### 다중 네트워크 인터페이스

```bash
# 여러 네트워크 인터페이스를 가진 VM 생성
gcloud compute instances create multi-nic-vm \
    --zone=asia-northeast1-a \
    --machine-type=n2-standard-4 \
    --network-interface=subnet=public-subnet \
    --network-interface=subnet=private-subnet,no-address
```

### 외부 IP 관리

```bash
# 고정 외부 IP 예약
gcloud compute addresses create web-server-ip \
    --region=asia-northeast1

# 예약된 IP로 VM 생성
gcloud compute instances create web-server \
    --zone=asia-northeast1-a \
    --address=web-server-ip

# 기존 VM에 외부 IP 추가
gcloud compute instances add-access-config web-server \
    --zone=asia-northeast1-a \
    --access-config-name="External NAT"

# 외부 IP 제거
gcloud compute instances delete-access-config web-server \
    --zone=asia-northeast1-a \
    --access-config-name="External NAT"

# IP 주소 목록 확인
gcloud compute addresses list
```

### 외부 IP 관리 - 웹 콘솔

> 📍 VPC 네트워크 > IP 주소 > 외부 고정 주소 예약

**고정 IP 예약:**
1. **이름**: `web-server-ip` 입력
2. **네트워크 서비스 등급**: `프리미엄` 선택
3. **IP 버전**: `IPv4` 선택
4. **유형**: `리전` 선택
5. **리전**: `asia-northeast1` 선택
6. **연결 대상**: `web-server` 선택 (또는 나중에 연결)
7. **예약** 클릭

**기존 VM에 외부 IP 연결:**
> 📍 Compute Engine > VM 인스턴스 > web-server > 수정

1. **네트워크 인터페이스** 편집 클릭
2. **외부 IPv4 주소**: 예약된 IP 선택
3. **저장** 클릭

### 내부 DNS 및 호스트명

```bash
# 커스텀 호스트명 설정
gcloud compute instances create web-server \
    --zone=asia-northeast1-a \
    --hostname=web.example.com

# 내부 DNS 이름으로 접근 (같은 VPC 내에서)
# <인스턴스-이름>.<존>.<프로젝트-ID>.internal
# 예: web-server.asia-northeast1-a.c.my-project.internal
```

---

## VM 관리 명령어

### 인스턴스 목록 및 상태

```bash
# 모든 VM 인스턴스 목록
gcloud compute instances list

# 특정 존의 VM 목록
gcloud compute instances list --zones=asia-northeast1-a

# 특정 VM 상세 정보
gcloud compute instances describe web-server \
    --zone=asia-northeast1-a

# VM 상태만 확인
gcloud compute instances describe web-server \
    --zone=asia-northeast1-a \
    --format="value(status)"
```

### VM 시작/중지/재시작

```bash
# VM 중지 (과금 중단, 디스크는 유지)
gcloud compute instances stop web-server \
    --zone=asia-northeast1-a

# VM 시작
gcloud compute instances start web-server \
    --zone=asia-northeast1-a

# VM 재시작 (OS 재부팅)
gcloud compute instances reset web-server \
    --zone=asia-northeast1-a

# 여러 VM 동시 작업
gcloud compute instances stop web-server-1 web-server-2 \
    --zone=asia-northeast1-a
```

### VM 시작/중지 - 웹 콘솔

> 📍 Compute Engine > VM 인스턴스

1. 대상 VM의 체크박스 선택
2. 상단 메뉴에서 **중지** / **시작** / **재설정** 클릭
3. 또는 VM 이름 클릭 > 상단의 **중지** / **시작** / **재설정** 버튼 클릭

### VM 삭제

```bash
# VM 삭제 (디스크도 함께 삭제)
gcloud compute instances delete web-server \
    --zone=asia-northeast1-a

# VM 삭제 (디스크 보존)
gcloud compute instances delete web-server \
    --zone=asia-northeast1-a \
    --keep-disks=all

# 부팅 디스크만 보존
gcloud compute instances delete web-server \
    --zone=asia-northeast1-a \
    --keep-disks=boot
```

### VM 메타데이터 수정

```bash
# 메타데이터 추가/수정
gcloud compute instances add-metadata web-server \
    --zone=asia-northeast1-a \
    --metadata=key1=value1,key2=value2

# 메타데이터 제거
gcloud compute instances remove-metadata web-server \
    --zone=asia-northeast1-a \
    --keys=key1,key2

# 스타트업 스크립트 업데이트
gcloud compute instances add-metadata web-server \
    --zone=asia-northeast1-a \
    --metadata-from-file=startup-script=startup.sh
```

### 라벨 관리

```bash
# 라벨 추가/수정
gcloud compute instances update web-server \
    --zone=asia-northeast1-a \
    --update-labels=environment=production,team=backend

# 라벨 제거
gcloud compute instances update web-server \
    --zone=asia-northeast1-a \
    --remove-labels=team
```

### 라벨 관리 - 웹 콘솔

> 📍 Compute Engine > VM 인스턴스 > web-server > 수정

1. **라벨** 섹션에서 **라벨 추가** 클릭
2. **키**: `environment`, **값**: `production` 입력
3. **저장** 클릭

---

## 메타데이터 및 서비스 계정

### VM 메타데이터 서버

```bash
# VM 내부에서 메타데이터 조회
curl -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/

# 인스턴스 정보
curl -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/name

# 프로젝트 정보
curl -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/project/project-id

# 액세스 토큰 (서비스 계정)
curl -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token
```

### 서비스 계정 설정

```bash
# 커스텀 서비스 계정으로 VM 생성
gcloud compute instances create web-server \
    --zone=asia-northeast1-a \
    --service-account=my-service-account@project-id.iam.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform

# 기존 VM의 서비스 계정 변경 (중지 상태에서만 가능)
gcloud compute instances stop web-server --zone=asia-northeast1-a
gcloud compute instances set-service-account web-server \
    --zone=asia-northeast1-a \
    --service-account=new-account@project-id.iam.gserviceaccount.com \
    --scopes=cloud-platform
gcloud compute instances start web-server --zone=asia-northeast1-a
```

### 서비스 계정 - 웹 콘솔

> 📍 Compute Engine > VM 인스턴스 > 인스턴스 만들기 (또는 기존 VM 수정)

1. **ID 및 API 액세스** 섹션
2. **서비스 계정**: 드롭다운에서 원하는 서비스 계정 선택
3. **액세스 범위**: `모든 Cloud API에 대한 전체 액세스 허용` 선택
4. **만들기** (또는 **저장**) 클릭

> 기존 VM의 서비스 계정 변경은 VM을 **중지** 상태에서만 가능

---

## 모니터링 및 로깅

### Cloud Monitoring 메트릭

```bash
# VM CPU 사용률 확인 (gcloud 명령어로는 제한적)
# Cloud Console에서 확인 권장

# 직렬 포트 출력 (부팅 로그 확인)
gcloud compute instances get-serial-port-output web-server \
    --zone=asia-northeast1-a
```

### 로그 확인

```bash
# VM 관련 로그 확인 (Cloud Logging)
gcloud logging read "resource.type=gce_instance AND \
    resource.labels.instance_id=<INSTANCE_ID>" \
    --limit=50 \
    --format=json
```
