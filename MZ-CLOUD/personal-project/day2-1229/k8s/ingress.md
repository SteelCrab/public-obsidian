# Ingress - Path-based Routing

> Ingress는 외부에서 클러스터 내부의 서비스로 HTTP/HTTPS 트래픽을 라우팅하는 규칙 모음

## 라우팅 구조

```
                    클라이언트
                         │
                         ▼
            ┌─────────────────────────────────────────────────────────┐
            │ Ingress Controller Service (NodePort)                   │
            │  NodePort: 30080                                        │
            │  ExternalIP: 172.100.100.20                             │
            └─────────────────────────────────────────────────────────┘
                         │
                         ▼
            ┌─────────────────────────────────────────────────────────┐
            │ Ingress (gition-ingress)                                │
            │  Host: gition.local                                     │
            └─────────────────────────────────────────────────────────┘
                    │    │    │
       /api/*       │    │    │ /*
       /auth/*      ▼    │    ▼
       /health           │
                    │    │    │
            ┌───────────────────────────────────────────────────────┐
            │ api-svc  │    │ frontend-svc                          │
            │ :3001    │    │ :80                                   │
            └───────────────────────────────────────────────────────┘
```

## 라우팅 테이블
| Path | Service | Port | 설명 |
|------|---------|------|------|
| `/api` | api-svc | 3001 | Backend API (Prefix) |
| `/auth/github` | api-svc | 3001 | GitHub OAuth (Prefix) |
| `/health` | api-svc | 3001 | Health Check (Exact) |
| `/` | frontend-svc | 80 | Frontend catch-all (Prefix) |

## 기본 설정

| 항목 | 값 |
|------|-----|
| **Host** | `gition.local` |
| **IngressClass** | nginx |
| **Namespace** | gition |

## Annotations (설정 주석)

| Annotation | 값 | 설명 |
|------------|-----|------|
| `proxy-body-size` | 50m | 파일 업로드 용량 |
| `proxy-connect-timeout` | 60 | 연결 타임아웃 |
| `proxy-read-timeout` | 60 | 응답 타임아웃 |

## 배포 명령어
```bash
# Ingress Controller NodePort 설정 (필요 시)
kubectl apply -f ingress-nginx-svc.yaml

# Ingress 라우팅 규칙 배포
kubectl apply -f ingress.yaml
kubectl get ingress -n gition
```

## 테스트 방법

```bash
# ExternalIP 사용 시
curl -H "Host: gition.local" http://172.100.100.20/

# NodePort 사용 시
curl -H "Host: gition.local" http://172.100.100.12:30080/

# API 테스트
curl -H "Host: gition.local" http://172.100.100.20/api/health
```