# GCP 인스턴스 템플릿 및 MIG

#gcp #compute #템플릿 #mig #오토스케일링

---

GCP 인스턴스 템플릿 생성, 관리형 인스턴스 그룹(MIG), 자동 확장 및 전체 관리 스크립트를 정리한 노트.

관련 문서: [[gcp-compute-engine]], [[gcp-vm-cost]]

## 인스턴스 템플릿

### 템플릿 생성

```bash
# 인스턴스 템플릿 생성
gcloud compute instance-templates create web-server-template \
    --machine-type=n2-standard-2 \
    --subnet=public-subnet \
    --region=asia-northeast1 \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-balanced \
    --tags=web-server,http-server \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install -y nginx
      systemctl start nginx'

# 템플릿 목록 확인
gcloud compute instance-templates list

# 템플릿 상세 정보
gcloud compute instance-templates describe web-server-template
```

### 템플릿 생성 - 웹 콘솔

> 📍 Compute Engine > 인스턴스 템플릿 > 인스턴스 템플릿 만들기

1. **이름**: `web-server-template` 입력
2. **머신 유형**: `n2-standard-2` 선택
3. **부팅 디스크** > 변경:
   - **운영체제**: `Ubuntu 22.04 LTS` 선택
   - **디스크 유형**: `균형 있는 영구 디스크` 선택
   - **크기**: `30` GB 입력
4. **네트워킹** > 네트워크 태그: `web-server, http-server` 입력
5. **네트워킹** > 네트워크 인터페이스 > 서브넷: `public-subnet` 선택
6. **관리** > 자동화 > **시작 스크립트**: nginx 설치 스크립트 붙여넣기
7. **만들기** 클릭

### 템플릿에서 VM 생성

```bash
# 템플릿으로 VM 인스턴스 생성
gcloud compute instances create web-server-1 \
    --source-instance-template=web-server-template \
    --zone=asia-northeast1-a

# 템플릿 옵션 오버라이드
gcloud compute instances create web-server-2 \
    --source-instance-template=web-server-template \
    --zone=asia-northeast1-b \
    --machine-type=n2-standard-4
```

---

## 관리형 인스턴스 그룹 (MIG)

### MIG 특징

| **항목** | **설명** |
|---------|---------|
| **자동 확장** | CPU, 메모리 사용률 기반 자동 스케일링 |
| **자동 복구** | 비정상 인스턴스 자동 재생성 |
| **로드 밸런싱** | 자동으로 로드 밸런서와 통합 |
| **롤링 업데이트** | 무중단 배포 지원 |
| **리전/존 MIG** | 리전 MIG는 여러 존에 분산 (고가용성) |

### 리전 MIG 생성 (권장)

```bash
# 리전 관리형 인스턴스 그룹 생성
gcloud compute instance-groups managed create web-server-mig \
    --base-instance-name=web-server \
    --template=web-server-template \
    --size=3 \
    --region=asia-northeast1 \
    --target-distribution-shape=EVEN

# 자동 확장 설정
gcloud compute instance-groups managed set-autoscaling web-server-mig \
    --region=asia-northeast1 \
    --min-num-replicas=2 \
    --max-num-replicas=10 \
    --target-cpu-utilization=0.75 \
    --cool-down-period=60

# 자동 복구 설정 (헬스 체크 기반)
gcloud compute health-checks create http web-health-check \
    --port=80 \
    --request-path=/ \
    --check-interval=10s \
    --timeout=5s \
    --unhealthy-threshold=3 \
    --healthy-threshold=2

gcloud compute instance-groups managed update web-server-mig \
    --region=asia-northeast1 \
    --health-check=web-health-check \
    --initial-delay=300
```

### 리전 MIG - 웹 콘솔

> 📍 Compute Engine > 인스턴스 그룹 > 인스턴스 그룹 만들기

1. **새 관리형 인스턴스 그룹 (스테이트리스)** 선택
2. **이름**: `web-server-mig` 입력
3. **위치**: `여러 영역` 선택
4. **리전**: `asia-northeast1` 선택
5. **인스턴스 템플릿**: `web-server-template` 선택
6. **인스턴스 수**: `3` 입력
7. **자동 확장**:
   - **자동 확장 모드**: `사용` 선택
   - **최소 인스턴스 수**: `2` 입력
   - **최대 인스턴스 수**: `10` 입력
   - **자동 확장 신호**: CPU 사용률 > `75`% 입력
   - **초기화 기간**: `60`초 입력
8. **자동 복구**:
   - **상태 확인**: `web-health-check` 선택
   - **초기 지연**: `300`초 입력
9. **만들기** 클릭

### 존 MIG 생성

```bash
# 존 관리형 인스턴스 그룹 생성
gcloud compute instance-groups managed create web-server-mig-zone \
    --base-instance-name=web-server \
    --template=web-server-template \
    --size=3 \
    --zone=asia-northeast1-a
```

### MIG 관리 명령어

```bash
# MIG 목록
gcloud compute instance-groups managed list

# MIG 크기 수동 조정
gcloud compute instance-groups managed resize web-server-mig \
    --region=asia-northeast1 \
    --size=5

# 롤링 업데이트 (새 템플릿 적용)
gcloud compute instance-groups managed rolling-action start-update web-server-mig \
    --region=asia-northeast1 \
    --version=template=web-server-template-v2 \
    --max-surge=3 \
    --max-unavailable=0

# MIG 인스턴스 목록
gcloud compute instance-groups managed list-instances web-server-mig \
    --region=asia-northeast1
```

---

## VM 전체 관리 스크립트

```bash
#!/bin/bash
# VM 인스턴스 생성 및 관리 자동화 스크립트

PROJECT_ID="named-foundry-486921-r5"
REGION="asia-northeast1"
ZONE="asia-northeast1-a"
VPC_NAME="pista-vpc"
SUBNET_NAME="public-subnet"

# 1. 인스턴스 템플릿 생성
echo "Creating instance template..."
gcloud compute instance-templates create web-template \
    --machine-type=n2-standard-2 \
    --subnet=$SUBNET_NAME \
    --region=$REGION \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-balanced \
    --tags=web-server,http-server \
    --metadata=startup-script='#!/bin/bash
      apt-get update && apt-get install -y nginx
      systemctl start nginx
      echo "Hello from $(hostname)" > /var/www/html/index.html'

# 2. 헬스 체크 생성
echo "Creating health check..."
gcloud compute health-checks create http web-health-check \
    --port=80 \
    --request-path=/ \
    --check-interval=10s \
    --timeout=5s

# 3. 리전 MIG 생성
echo "Creating managed instance group..."
gcloud compute instance-groups managed create web-mig \
    --base-instance-name=web \
    --template=web-template \
    --size=2 \
    --region=$REGION \
    --health-check=web-health-check \
    --initial-delay=300

# 4. 자동 확장 설정
echo "Setting up autoscaling..."
gcloud compute instance-groups managed set-autoscaling web-mig \
    --region=$REGION \
    --min-num-replicas=2 \
    --max-num-replicas=5 \
    --target-cpu-utilization=0.75 \
    --cool-down-period=60

echo "VM infrastructure setup complete!"

# 5. 상태 확인
gcloud compute instance-groups managed list
gcloud compute instance-groups managed list-instances web-mig \
    --region=$REGION
```
