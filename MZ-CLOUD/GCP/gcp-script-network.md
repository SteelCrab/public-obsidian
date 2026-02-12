# GCP 스크립트 - 네트워크 모듈

#gcp #스크립트 #network #vpc

---

GCP 인프라의 기본이 되는 VPC, 서브넷, Cloud NAT, 방화벽 규칙을 구축한다.
**모든/대부분의 스크립트 실행 전 가장 먼저 실행해야 하는 필수 스크립트이다.**

> 관련 문서: [[GCP_Infra_MOC]] | [[gcp-script-env]] | [[gcp-vpc]] | [[gcp-cloud-nat]]

## 파일

| 파일 | 용도 |
|------|------|
| `gcp-network-setup.sh` | VPC, 서브넷, Router/NAT, 방화벽 전체 생성 |
| `gcp-network-cleanup.sh` | 네트워크 리소스 전체 삭제 |

---

## 생성 리소스

| 리소스 | 이름 | 설명 |
|--------|------|------|
| VPC | `pista-vpc` | Custom Mode, Regional Routing |
| Public Subnet | `pista-public-subnet` | `10.0.1.0/24` |
| Private Subnet | `pista-private-subnet` | `10.0.2.0/24` (Private Google Access On) |
| Cloud Router | `pista-router` | NAT를 위한 라우터 |
| Cloud NAT | `pista-nat` | Private 서브넷의 아웃바운드 인터넷 허용 |
| 방화벽 | `allow-*-pista-vpc` | SSH(22), HTTP(80/443), Internal(All), Health Check |

---

## 실행

```bash
bash gcp-network-setup.sh
```

---

## 정리

**주의**: VM, GKE, DB 등 의존 리소스가 남아 있으면 삭제되지 않을 수 있습니다. 의존 리소스를 먼저 정리하세요.

```bash
bash gcp-network-cleanup.sh
```
