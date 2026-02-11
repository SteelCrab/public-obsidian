# GCP 스크립트 - VM 모듈

#gcp #스크립트 #vm #nginx

---

VPC 네트워크와 VM 인스턴스 2대(Public + Private)를 구축하는 모듈이다.

> 관련 문서: [[GCP_Scripts_MOC]] | [[gcp-script-env]] | [[gcp-compute-engine]] | [[gcp-vpc]]

## 파일

| 파일 | 용도 |
|------|------|
| `gcp-vm-setup.sh` | VPC + VM 2대 구축 |
| `gcp-vm-cleanup.sh` | VM 2대 삭제 (VPC 유지) |

---

## 생성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| 공유 네트워크 | - | VPC+서브넷+Router+NAT+방화벽 ([[gcp-script-env\|ensure_network]]) |
| Public VM | `pista-public-nginx` | Public 서브넷, 외부 IP, Nginx, e2-micro |
| Private VM | `pista-private-nginx` | Private 서브넷, 내부 전용, Nginx, e2-micro |

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
