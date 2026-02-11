# Ingress 전체 흐름

> LoadBalancer Service + Ingress 라우팅 통합 구성도

## 전체 흐름

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              Client (Browser)                                 │
│                         http://gition.local                                   │
└───────────────────────────────────┬───────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    LoadBalancer Service                                       │
│                    (ingress-nginx-controller)                                 │
│                                                                              │
│    externalIPs: 172.100.100.20:80                                            │
│    NodePort: 30080 (대체 경로)                                                │
└───────────────────────────────────┬───────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    Ingress Controller Pod                                     │
│                    (nginx-ingress-controller)                                 │
└───────────────────────────────────┬───────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    Ingress Resource (gition-ingress)                          │
│                    Host: gition.local                                         │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   /api/*         ──────────►  api-svc:3001  ──────►  FastAPI Pods            │
│   /auth/github   ──────────►  api-svc:3001  ──────►  FastAPI Pods            │
│   /health        ──────────►  api-svc:3001  ──────►  FastAPI Pods            │
│   /* (catch-all) ──────────►  frontend-svc:80 ────►  React Pods              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## 구성 요소

| 구성 요소 | 파일 | 역할 |
|-----------|------|------|
| LoadBalancer Service | `ingress-nginx-svc.yaml` | 외부 접근점 (IP/포트) |
| Ingress Resource | `ingress.yaml` | 라우팅 규칙 (경로 분배) |

## 접근 방법

| 방법 | 주소 | 설명 |
|------|------|------|
| **ExternalIP** | `http://172.100.100.20` | 권장 |
| **NodePort** | `http://<NodeIP>:30080` | 대체 |
| **도메인** | `http://gition.local` | hosts 파일 설정 필요 |

## 라우팅 규칙

| Path | Backend | 설명 |
|------|---------|------|
| `/api` | api-svc:3001 | Backend API |
| `/auth/github` | api-svc:3001 | GitHub OAuth |
| `/health` | api-svc:3001 | Health Check |
| `/` | frontend-svc:80 | Frontend (catch-all) |
