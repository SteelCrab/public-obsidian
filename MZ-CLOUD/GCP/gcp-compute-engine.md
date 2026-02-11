# GCP Compute Engine - VM 인스턴스

#gcp #compute #vm #인스턴스

---

GCP Compute Engine VM 인스턴스의 개요, 머신 타입, 생성 방법을 정리한 노트.

관련 문서: [[gcp-vpc]], [[gcp-vm-disk]], [[gcp-vm-management]], [[gcp-vm-ssh]]

## 1. VM 인스턴스 개요

### Compute Engine 특징

| **항목** | **설명** |
|---------|---------|
| **리소스 종류** | 존(Zone) 리소스 (특정 존에 생성) |
| **운영체제** | Linux, Windows, Container-Optimized OS 등 |
| **머신 타입** | 범용, 컴퓨팅 최적화, 메모리 최적화, GPU 등 |
| **디스크** | 영구 디스크(PD), 로컬 SSD, 부팅 디스크 |
| **네트워킹** | VPC, 서브넷, 외부/내부 IP, 방화벽 규칙 |
| **비용 절감** | 지속 사용 할인, 약정 사용 할인, 선점형 VM |

---

## 2. 머신 타입 (Machine Types)

### 머신 패밀리 비교

| **패밀리** | **용도** | **머신 시리즈** | **특징** |
|---------|---------|--------------|---------|
| **범용 (E2)** | 일반 워크로드 | `e2-standard`, `e2-highmem`, `e2-highcpu` | 비용 효율적, 일반적인 애플리케이션 |
| **범용 (N1)** | 균형잡힌 워크로드 | `n1-standard`, `n1-highmem`, `n1-highcpu` | 안정적, 다양한 워크로드 |
| **범용 (N2/N2D)** | 향상된 성능 | `n2-standard`, `n2d-standard` | 최신 CPU, 높은 성능 |
| **컴퓨팅 최적화 (C2)** | CPU 집약적 워크로드 | `c2-standard` | 고성능 컴퓨팅, 게임 서버 |
| **메모리 최적화 (M2)** | 메모리 집약적 워크로드 | `m2-ultramem`, `m2-megamem` | 대용량 인메모리 데이터베이스 |

### 머신 타입 네이밍 규칙

```
<시리즈>-<워크로드-유형>-<vCPU-수>

예시:
- n2-standard-4    : N2 시리즈, 표준 (4 vCPU, 16GB RAM)
- e2-highmem-8     : E2 시리즈, 고메모리 (8 vCPU, 64GB RAM)
- c2-standard-16   : C2 시리즈, 표준 (16 vCPU, 64GB RAM)
```

### 머신 타입 조회

```bash
# 특정 존의 머신 타입 목록
gcloud compute machine-types list --zones=asia-northeast1-a

# 특정 시리즈 필터링
gcloud compute machine-types list \
    --zones=asia-northeast1-a \
    --filter="name:n2-standard*"

# 머신 타입 상세 정보
gcloud compute machine-types describe n2-standard-4 \
    --zone=asia-northeast1-a
```

---

## 3. VM 인스턴스 생성

### 기본 VM 생성

```bash
# 간단한 VM 생성
gcloud compute instances create my-vm \
    --zone=asia-northeast1-a \
    --machine-type=e2-medium

# 상세 옵션 VM 생성
gcloud compute instances create web-server \
    --zone=asia-northeast1-a \
    --machine-type=n2-standard-4 \
    --subnet=public-subnet \
    --network-tier=PREMIUM \
    --maintenance-policy=MIGRATE \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=50GB \
    --boot-disk-type=pd-balanced \
    --boot-disk-device-name=web-server-boot \
    --tags=web-server,http-server \
    --labels=environment=production,team=backend \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install -y nginx
      systemctl start nginx
      echo "Hello from $(hostname)" > /var/www/html/index.html'
```

### 웹 콘솔

> 📍 Compute Engine > VM 인스턴스 > 인스턴스 만들기

1. **이름**: `web-server` 입력
2. **리전**: `asia-northeast1 (도쿄)` 선택
3. **영역**: `asia-northeast1-a` 선택
4. **머신 구성**:
   - **시리즈**: `N2` 선택
   - **머신 유형**: `n2-standard-4` 선택
5. **부팅 디스크** > 변경 클릭:
   - **운영체제**: `Ubuntu` 선택
   - **버전**: `Ubuntu 22.04 LTS` 선택
   - **디스크 유형**: `균형 있는 영구 디스크` 선택
   - **크기**: `50` GB 입력
6. **네트워킹**:
   - **네트워크 태그**: `web-server, http-server` 입력
   - **네트워크 인터페이스** > 서브넷: `public-subnet` 선택
7. **관리** > 라벨 > **라벨 추가**: `environment=production`, `team=backend`
8. **관리** > 자동화 > **시작 스크립트**: 스크립트 붙여넣기
9. **만들기** 클릭

### VM 생성 주요 옵션

| **옵션** | **설명** | **예시 값** |
|---------|---------|-----------|
| `--zone` | VM을 생성할 존 | `asia-northeast1-a` (서울) |
| `--machine-type` | 머신 타입 | `n2-standard-4`, `e2-medium` |
| `--subnet` | 서브넷 지정 | `public-subnet` |
| `--network-tier` | 네트워크 티어 | `PREMIUM` (기본), `STANDARD` |
| `--image-family` | OS 이미지 패밀리 | `ubuntu-2204-lts`, `debian-11` |
| `--image-project` | 이미지 프로젝트 | `ubuntu-os-cloud`, `debian-cloud` |
| `--boot-disk-size` | 부팅 디스크 크기 | `50GB`, `100GB` |
| `--boot-disk-type` | 디스크 유형 | `pd-balanced`, `pd-ssd`, `pd-standard` |
| `--tags` | 네트워크 태그 (방화벽 규칙 적용) | `web-server`, `database` |
| `--labels` | 라벨 (리소스 관리용) | `env=prod`, `team=backend` |
| `--metadata` | 메타데이터 (스타트업 스크립트 등) | `startup-script=...` |
| `--no-address` | 외부 IP 할당 안 함 | 플래그 설정 |
| `--address` | 고정 외부 IP 지정 | 예약된 IP 주소 |
| `--preemptible` | 선점형 VM (저렴, 최대 24시간) | 플래그 설정 |
| `--spot` | Spot VM (선점형 개선 버전) | 플래그 설정 |

### 커스텀 머신 타입 생성

```bash
# 커스텀 CPU와 메모리 지정 (vCPU 4개, RAM 8GB)
gcloud compute instances create custom-vm \
    --zone=asia-northeast1-a \
    --custom-cpu=4 \
    --custom-memory=8GB

# 확장 메모리 커스텀 머신 (vCPU당 최대 8GB 메모리)
gcloud compute instances create custom-highmem-vm \
    --zone=asia-northeast1-a \
    --custom-cpu=4 \
    --custom-memory=32GB \
    --custom-extensions
```
