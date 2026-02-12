# GCP 스크립트 - GCS 정적 사이트 모듈

#gcp #스크립트 #GCS #CDN #정적사이트

---

Cloud Storage 버킷을 백엔드로 사용하는 HTTP Load Balancer + CDN을 구축하는 모듈이다. VPC 불필요 — 완전 독립 실행.

> 관련 문서: [[GCP_Infra_MOC]] | [[gcp-script-env]] | [[gcp-storage-bucket]] | [[gcp-storage-web]]

## 파일

| 파일 | 용도 |
|------|------|
| `gcp-gcs-setup.sh` | GCS 버킷 + HTTP LB (정적 사이트 + CDN) 구축 |
| `gcp-gcs-cleanup.sh` | GCS LB + 버킷 삭제 |

---

## 생성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| GCS 버킷 | `pista-static-site` | STANDARD, 균일 버킷 수준 액세스 |
| 공개 설정 | - | `allUsers` → `objectViewer` |
| 정적 파일 | - | `index.html`, `404.html` 업로드 |
| 백엔드 버킷 | `pista-static-backend` | CDN 활성화 |
| URL Map | `pista-static-url-map` | 기본 라우팅 |
| HTTP Proxy | `pista-static-http-proxy` | Target HTTP Proxy |
| 전역 IP | `pista-static-lb-ip` | 전역 외부 IP |
| Forwarding Rule | `pista-static-http-rule` | HTTP:80 → HTTP Proxy |

---

## 트래픽 흐름

```
클라이언트 → 전역 IP → HTTP Proxy → URL Map → Backend Bucket (CDN) → GCS 버킷
```

---

## 실행

```bash
bash gcp-gcs-setup.sh
```

---

## 테스트

```bash
# LB 경유 (프로비저닝 후 1~3분 대기)
curl http://<LB_IP>

# 버킷 직접 접속
curl https://storage.googleapis.com/pista-static-site/index.html
```

---

## 정리

```bash
bash gcp-gcs-cleanup.sh
```

> 공개 설정은 버킷 삭제 시 같이 제거된다.
