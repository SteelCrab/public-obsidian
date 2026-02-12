# GCP 3일 집중 학습 플랜 (2026-02-11 ~ 2026-02-13)

> AWS 경험을 바탕으로 GCP의 핵심 서비스(Compute, Network, DB, K8s)를 3일간 빠르게 습득하는 커리큘럼입니다.

## 📅 일정 개요

| 날짜 | 주제 | 핵심 내용 | 비고 |
|------|------|----------|------|
| **1일차 (02-11)** | **Compute & Network** | GCS 정적 웹, LB, MIG, 오토스케일링 | ✅ 완료 (문서화 됨) |
| **2일차 (02-12)** | **Database & Storage** | Cloud SQL (HA/백업), Private Connectivity | 🚧 진행 예정 |
| **3일차 (02-13)** | **Containers & Ops** | Cloud Run, GKE 기초, Monitoring | 🗓️ 예정 |

---

## 🚀 1일차: Compute & Load Balancing (2026-02-11)

**목표**: 고가용성 웹 서비스 아키텍처 구축

- [x] **GCS 정적 웹사이트 + LB**
    - Cloud Storage 버킷 생성 및 정적 웹 호스팅 설정
    - HTTP(S) Load Balancer + Cloud CDN 연동
- [x] **Managed Instance Group (MIG)**
    - Instance Template (e2-micro, Nginx) 작성
    - MIG 생성 (리전 분산, 자동 복구)
    - 오토스케일링 정책 (CPU 75%) 설정
- [x] **HTTP(S) Load Balancing**
    - URL Map → Backend Service (MIG) 연결
    - Health Check 구성

→ **결과물**: `MZ-CLOUD/GCP/2026-02-11.md`

---

## 💾 2일차: Managed Database & Storage (2026-02-12)

**목표**: 완전 관리형 데이터베이스 구축 및 보안 연결

- [ ] **Cloud SQL (MySQL 8.0)**
    - 인스턴스 생성 (Regional HA 구성)
    - **Cloud SQL Auth Proxy**를 통한 로컬/원격 보안 접속
    - Private IP 연결 (Private Service Access, VPC Peering)
- [ ] **데이터 운영**
    - 사용자 및 데이터베이스 관리
    - **백업 및 복구**: 자동 백업 설정, PITR(Point-in-Time Recovery) 실습
    - AWS RDS와의 차이점 비교 (Multi-AZ vs Regional HA)
- [ ] **Cloud Storage 심화**
    - 수명 주기(Lifecycle) 정책 설정 (자동 삭제/계층 이동)
    - Signed URL (임시 접근 권한) 생성

→ **예상 결과물**: `MZ-CLOUD/GCP/2026-02-12.md`

---

## ☸️ 3일차: Containers & Operations (2026-02-13)

**목표**: 컨테이너 워크로드 및 운영 모니터링

- [ ] **Google Kubernetes Engine (GKE)**
    - GKE Standard vs Autopilot 차이 이해
    - **VPC Native Cluster** 생성 (Pod/Service IP 대역 분리)
    - `kubectl` 연동 및 간단한 Nginx 배포 (LoadBalancer 타입)
- [ ] **Cloud Run (Serverless)**
    - Docker 이미지 빌드 (Artifact Registry)
    - Cloud Run 서비스 배포 (트래픽 0일 때 비용 0원)
- [ ] **Cloud Operations (Stackdriver)**
    - **Cloud Logging**: 로그 뷰어 사용법, 고급 필터링
    - **Cloud Monitoring**: VM/DB 대시보드 생성, 알림 정책(Alerting) 설정

→ **예상 결과물**: `MZ-CLOUD/GCP/2026-02-13.md`
