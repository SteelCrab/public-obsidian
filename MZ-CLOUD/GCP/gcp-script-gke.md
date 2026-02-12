# GCP 스크립트 - GKE 모듈

#gcp #스크립트 #gke #kubernetes #gar

---

GCP의 **GKE (Google Kubernetes Engine)**와 **GAR (Artifact Registry)**를 사용하여 컨테이너화된 애플리케이션(Nginx, FastAPI)을 배포하는 모듈이다.

> 관련 문서: [[GCP_Infra_MOC]] | [[gcp-script-network]] | [[gcp-gke]]

## 사전 요구사항
* **네트워크 구축 필수**: `bash gcp-network-setup.sh`
* **Docker Desktop**: 로컬 머신에 Docker가 실행 중이어야 함.
* **소스 코드**: `Projects/nginx`, `Projects/fastapi` 소스 필요.

---

## 파일

| 파일 | 용도 |
|------|------|
| `gcp-gke-setup.sh` | GAR 생성 + Docker Build/Push + GKE 생성 + K8s 배포 |
| `gcp-gke-cleanup.sh` | K8s 리소스, GKE 클러스터, GAR 저장소 삭제 |

---

## 생성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| Artifact Registry | `pista-repo` | Docker 이미지 저장소 (Seoul) |
| GKE Cluster | `pista-cluster` | Zonal, 1 Node, e2-medium (Standard) |
| Deployment (1) | `pista-nginx` | Nginx 웹서버 (Replicas: 1) |
| Service (1) | `pista-nginx` | LoadBalancer (Port 80) |
| Deployment (2) | `pista-fastapi` | FastAPI 애플리케이션 (Replicas: 1) |
| Service (2) | `pista-fastapi` | LoadBalancer (Port 8000) |

---

## 실행 프로세스

```bash
# 1. 네트워크 구축 (최초 1회)
bash gcp-network-setup.sh

# 2. GKE 구축 및 배포
bash gcp-gke-setup.sh
```

**진행 과정:**
1. 필수 API 활성화 (`artifactregistry`, `container`)
2. GAR 저장소(`pista-repo`) 생성
3. **Nginx** & **FastAPI** Docker 이미지 빌드 및 푸시
4. GKE 클러스터(`pista-cluster`) 생성
5. Kubernetes Deployment & Service 배포

---

## 테스트

```bash
# Nginx 접속
curl http://<NGINX_EXTERNAL_IP>

# FastAPI 접속 (Docs)
curl http://<FASTAPI_EXTERNAL_IP>:8000/docs
```
※ IP 확인: `kubectl get service`

---

## 정리

```bash
bash gcp-gke-cleanup.sh
```
> 클러스터 삭제에 약 5분 정도 소요됩니다.
