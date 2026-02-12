# GCP (Google Cloud Platform)

#gcp #cloud #moc

---

GCP 관련 노트 모음

## gcloud CLI
- [[gcp-cli]] - gcloud CLI 설치 및 초기 설정

## 네트워크
- [[gcp-vpc]] - VPC 및 서브넷
- [[gcp-cloud-nat]] - Cloud NAT 및 인터넷 게이트웨이
- [[gcp-firewall]] - 방화벽 규칙
- [[gcp-network-lab]] - 네트워크 구축 실습 (AWS vs GCP 비교 포함)

## Compute Engine
- [[gcp-compute-engine]] - VM 인스턴스 개요, 머신 타입, 생성
- [[gcp-vm-disk]] - 디스크 관리
- [[gcp-vm-management]] - VM 관리 명령어 (네트워크, 메타데이터, 모니터링)
- [[gcp-vm-ssh]] - SSH 접속 및 SCP
- [[gcp-instance-template]] - 인스턴스 템플릿 및 MIG
- [[gcp-snapshot]] - 스냅샷 및 이미지
- [[gcp-vm-cost]] - 비용 최적화

## Containers & Kubernetes
- [[gcp-gke]] - GKE 클러스터 및 Artifact Registry (GAR) 구축
- [[gcp-gke-setup]] - (스크립트) GKE 구축 자동화

## 구축 스크립트
- [[gcp-scripts]] - 전체 스크립트 가이드 (Network, VM, GKE, DB, LB)

## 네트워크 (고급)
- [[gcp-load-balancer]] - Load Balancer (HTTP/S, TCP/UDP, 내부, CDN)

## Cloud Storage
- [[gcp-cloud-storage]] - Cloud Storage 개요 및 스토리지 클래스
- [[gcp-storage-bucket]] - 버킷 생성 및 관리
- [[gcp-storage-object]] - 객체 관리 (업로드, 다운로드, rsync)
- [[gcp-storage-iam]] - 접근 제어 및 조직 정책
- [[gcp-storage-lifecycle]] - 버전 관리 및 수명 주기
- [[gcp-storage-event]] - 알림 및 이벤트 (Pub/Sub)
- [[gcp-storage-web]] - 정적 웹사이트 호스팅

## Cloud SQL
- [[gcp-cloud-sql]] - Cloud SQL 개요, 인스턴스 생성, DB/사용자 관리
- [[gcp-cloud-sql-connect]] - 연결 방법 (Auth Proxy, Private IP, Public IP)
- [[gcp-cloud-sql-ha]] - 고가용성, 백업, 읽기 복제본
- [[gcp-cloud-sql-ops]] - 운영 관리 및 구축 스크립트

## 학습
* [[MZ-CLOUD/GCP/2026-02-11|2026-02-11]]
	*  GCS 정적 웹사이트 + Load Balancer
	* HTTP(S) LB + 인스턴스 그룹 + 템플릿 구성
* [[MZ-CLOUD/GCP/2026-02-12|2026-02-12]]
	* GCP 네트워크 인프라 구성 (VPC, NAT, Firewall)
	* VM 인스턴스 구성 (Public + Private)
	* VM 인스턴스 구성 (Public + Private)
	* Private VM 접속 (SSH 터널링)
	* [[gcp-gke]] - GKE + Artifact Registry (GAR) 구축
	* Nginx & FastAPI 멀티 배포 (LoadBalancer)

## 기타
- [[CloudVPC]] - Cloud VPC 템플릿
