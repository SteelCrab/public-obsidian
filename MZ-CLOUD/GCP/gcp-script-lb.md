# GCP 스크립트 - Load Balancer 모듈

#gcp #스크립트 #로드밸런서 #MIG #오토스케일링

---

인스턴스 템플릿 + MIG + HTTP Load Balancer를 구축하는 모듈이다. 오토스케일링(2~5대)과 자동 복구가 포함된다.

> 관련 문서: [[GCP_Infra_MOC]] | [[gcp-script-env]] | [[gcp-load-balancer]] | [[gcp-instance-template]]

## 파일

| 파일 | 용도 |
|------|------|
| `gcp-lb-setup.sh` | 인스턴스 템플릿 + MIG + HTTP LB 구축 |
| `gcp-lb-cleanup.sh` | LB 전체 삭제 (역순 정리) |

---

## 사전 요구사항
* **네트워크 구축 필수**: `bash gcp-network-setup.sh` 실행 필요.

---

## 생성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| 인스턴스 템플릿 | `pista-web-template` | e2-micro, Nginx, Ubuntu 24.04 LTS |
| 헬스 체크 | `pista-health-check` | HTTP:80, 10초 간격 |
| MIG | `pista-web-mig` | 리전 MIG, 2~5대, CPU 75% 오토스케일링 |
| 백엔드 서비스 | `pista-backend-service` | MIG 연결, max utilization 80% |
| URL Map | `pista-url-map` | 기본 라우팅 |
| HTTP Proxy | `pista-http-proxy` | Target HTTP Proxy |
| 전역 IP | `pista-lb-ip` | 전역 외부 IP |
| Forwarding Rule | `pista-http-rule` | HTTP:80 → HTTP Proxy |

---

## 실행

```bash
bash gcp-lb-setup.sh
```

---

## 테스트

```bash
# LB 접속 (프로비저닝 후 1~3분 대기)
curl http://<LB_IP>

# 분산 확인 (인스턴스별 응답 차이 확인)
for i in $(seq 1 10); do curl -s http://<LB_IP> | grep Instance; done

# MIG 인스턴스 목록
gcloud compute instance-groups managed list-instances pista-web-mig --region=asia-northeast1

# 백엔드 헬스 상태
gcloud compute backend-services get-health pista-backend-service --global
```

---

## 정리

```bash
bash gcp-lb-cleanup.sh
```

> Cleanup 순서: Forwarding Rule → HTTP Proxy → URL Map → Backend Service → MIG → Health Check → Template → IP
