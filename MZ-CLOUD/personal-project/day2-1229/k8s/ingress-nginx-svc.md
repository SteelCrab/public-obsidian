# Ingress-Nginx Controller Service

> Ingress Controller를 NodePort 30080으로 고정하여 노출함

## 구분
| 파일명 | 설명 |
|--------|------|
| `ingress.yaml` | 라우팅 규칙 (도메인 기반 연결 규칙) |
| `ingress-nginx-svc.yaml` | **Controller 외부 노출** (외부 접근용) |

## 상세 설정

| 항목 | 값 |
|------|-----|
| **Type** | LoadBalancer |
| **ExternalIP** | 172.100.100.20 |
| **HTTP NodePort** | 30080 |
| **HTTPS NodePort** | 30443 |
| **Namespace** | ingress-nginx |

## 포트 흐름

```
┌──────────────────────────────────────────────────────────────────────┐
│                        LoadBalancer Service                          │
│                    (ingress-nginx-controller)                        │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ① ExternalIP 접근 (권장)                                            │
│  ───────────────────────                                             │
│     Client                                                           │
│        │                                                             │
│        ▼                                                             │
│   172.100.100.20:80  ─────────►  Ingress Controller Pod:80           │
│                                                                      │
│  ② NodePort 접근 (대체)                                              │
│  ─────────────────────                                               │
│     Client                                                           │
│        │                                                             │
│        ▼                                                             │
│   <NodeIP>:30080  ────────────►  Ingress Controller Pod:80           │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

## 포트 매핑

| 프로토콜 | Service Port | NodePort | Target (Pod) |
|----------|--------------|----------|--------------|
| HTTP | 80 | 30080 | 80 |
| HTTPS | 443 | 30443 | 443 |

## 배포
```bash
kubectl apply -f ingress-nginx-svc.yaml
kubectl get svc -n ingress-nginx
```

## 테스트

```bash
# ExternalIP 사용 (권장)
curl -H "Host: gition.local" http://172.100.100.20/

# NodePort 사용
curl -H "Host: gition.local" http://<NodeIP>:30080/
```
