# Frontend (React + Nginx) Deployment

> ConfigMap으로 nginx 설정을 관리하고, Ingress 규칙에 따라 트래픽을 받음

## 구성 요소

| 리소스 | 이름 | 네임스페이스 |
|--------|------|-------------|
| ConfigMap | `nginx-config` | gition |
| Deployment | `frontend` | gition |
| Service | `frontend-svc` | gition |

## 라우팅 구조

```
Ingress (gition.local)
    │
    ├───> /api/*    -> api-svc:3001
    ├───> /auth/*   -> api-svc:3001
    └───> /*        -> frontend-svc:80
                        │
                        └──> nginx (ConfigMap 설정)
                              └──> 정적 파일 서빙
```

## 컨테이너 설정

| 항목 | 값 |
|------|-----|
| **Replicas** | 2 |
| **이미지** | `172.100.100.8:5050/root/gition/frontend:latest` |
| **포트** | 80 |
| **imagePullSecrets** | `gitlab-registry` |
| **ConfigMap** | `nginx-config` |

## ConfigMap (nginx 설정)

| 설정 | 값 |
|------|-----|
| Gzip 압축 | 활성화 |
| 정적 파일 캐시 | 1년 |
| Health endpoint | `/health` -> 200 OK |
| SPA fallback | `try_files $uri /index.html` |

## 리소스 제한

| 항목 | Requests | Limits |
|------|----------|--------|
| CPU | 50m | 200m |
| Memory | 64Mi | 256Mi |

## Health Check

| Probe | Path | Initial Delay | Period |
|-------|------|---------------|--------|
| Liveness | `/health` | 5s | 10s |
| Readiness | `/health` | 3s | 5s |

## 배포 명령어
```bash
kubectl apply -f frontend.yaml
kubectl get pods -n gition -l app=frontend
```

## nginx 설정 변경 시

ConfigMap이 수정되면 Pod를 재시작해야 적용됨

```bash
kubectl apply -f frontend.yaml
kubectl rollout restart deployment/frontend -n gition
```

## 새 이미지를 배포 하는 경우 (frontend)
```bash
kubectl rollout restart deployment/frontend -n gition && kubectl rollout status deployment/frontend -n gition
```