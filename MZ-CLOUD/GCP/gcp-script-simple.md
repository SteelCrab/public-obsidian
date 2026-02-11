# GCP 스크립트 - 심플 VM 모듈

#gcp #스크립트 #vm #심플

---

최소 구성 VM 2대(Public + Private)를 빠르게 구축하는 모듈이다. VM 모듈과 별도의 인스턴스를 사용한다.

> 관련 문서: [[GCP_Scripts_MOC]] | [[gcp-script-env]] | [[gcp-script-vm]] | [[gcp-compute-engine]]

## 파일

| 파일 | 용도 |
|------|------|
| `gcp-simple-setup.sh` | 심플 VM 2대 (Public + Private) 구축 |
| `gcp-simple-cleanup.sh` | 심플 VM 2대 삭제 (VPC 유지) |

---

## 생성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| Public VM | `pista-pub-nginx` | Public 서브넷, 외부 IP, Nginx, e2-micro |
| Private VM | `pista-priv-nginx` | Private 서브넷, 내부 전용, Nginx, e2-micro |

---

## 네트워크 구성

```
pista-public-subnet  → pista-pub-nginx  (외부 IP + Nginx)
pista-private-subnet → pista-priv-nginx (내부 전용, NAT 아웃바운드)
```

---

## 실행

```bash
bash gcp-simple-setup.sh
```

---

## 테스트

```bash
# 1) Public 외부 접속
curl http://<PUBLIC_IP>

# 2) Public SSH
gcloud compute ssh pista-pub-nginx --zone=asia-northeast1-a

# 3) Public → Private 내부 통신
gcloud compute ssh pista-pub-nginx --zone=asia-northeast1-a \
    --command="curl http://<PRIVATE_INTERNAL_IP>"

# 4) Private SSH (Bastion 경유)
gcloud compute ssh pista-pub-nginx --zone=asia-northeast1-a
ssh <PRIVATE_INTERNAL_IP>
```

---

## 정리

```bash
bash gcp-simple-cleanup.sh    # VM만 삭제, VPC 유지
```
