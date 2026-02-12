# GCP 스크립트 - VM 모듈

#gcp #스크립트 #vm #nginx

---

VPC 네트워크와 VM 인스턴스 2대(Public + Private)를 구축하는 모듈이다.

> 관련 문서: [[GCP_Infra_MOC]] | [[gcp-script-env]] | [[gcp-compute-engine]] | [[gcp-vpc]]

## 파일

| 파일 | 용도 |
|------|------|
| `gcp-vm-setup.sh` | VPC + VM 2대 구축 |
| `gcp-vm-cleanup.sh` | VM 2대 삭제 (VPC 유지) |

---

## 사전 요구사항
* **네트워크 구축 필수**: `bash gcp-network-setup.sh`가 먼저 실행되어 있어야 한다.

---

## 생성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| Public VM | `pista-public-nginx` | Public 서브넷, 외부 IP, Nginx, e2-micro (Ubuntu 24.04) |
| Private VM | `pista-private-nginx` | Private 서브넷, 내부 전용, Nginx, e2-micro (Ubuntu 24.04) |

---

## 실행

```bash
bash gcp-vm-setup.sh
```

---

## 테스트

```bash
# Public 외부 접속
curl http://<PUBLIC_IP>

# SSH 접속
gcloud compute ssh pista-public-nginx --zone=asia-northeast1-a
```

---

## 정리

```bash
bash gcp-vm-cleanup.sh    # VM만 삭제, VPC 유지
```
