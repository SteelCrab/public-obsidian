# FastAPI Backend Deployment

> FastAPI 기반 Python API 서버와 Kubernetes 배포 설정 (공유 저장소 포함)

## 주요 구성 요소

| 리소스 | 이름 | 네임스페이스 | 설명 |
|--------|------|-------------|------|
| PersistentVolumeClaim | `repos-pvc` | gition | Git 저장소 공유를 위한 NFS 볼륨 (5Gi, RWX) |
| Deployment | `api` | gition | 백엔드 애플리케이션 (Replicas: 3) |
| Service | `api-svc` | gition | 백엔드 서비스 (Port: 3001) |

## 컨테이너 설정

| 항목 | 값 |
|------|-----|
| **Replicas** | 3 (3개의 Pod가 저장소 공유) |
| **이미지** | `172.100.100.8:5050/root/gition/backend:latest` |
| **포트** | 3001 |
| **imagePullSecrets** | `gitlab-registry` |

## 공유 저장소 (Shared Storage)

Replicas가 3개이므로, 모든 Pod가 동일한 Git 저장소 데이터를 볼 수 있도록 NFS PVC를 마운트함

| 종류 | 이름 | 마운트 경로 |
|------|-----|------|
| **VolumeMount** | `repos-volume` | `/repos` |
| **PVC** | `repos-pvc` | `nfs-client` StorageClass 사용 |

## 환경 변수 설정

### Database

| 변수명 | 값 | 설명 |
|------|-----|------|
| `MYSQL_READ_HOST` | mysql-master | 현재 Master에서 Read/Write 모두 처리 |
| `MYSQL_WRITE_HOST` | mysql-master | 쓰기 전용 DB (Master) |
| `MYSQL_PORT` | 3306 | MySQL 포트 |
| `MYSQL_USER` | pista | DB 사용자 |
| `MYSQL_DATABASE` | gition | DB 이름 |
| `MYSQL_PASSWORD` | Secret 참조 | `mysql-secret.user-password` |

### Application URLs

| 변수명 | 값 | 설명 |
|------|-----|------|
| `BASE_URL` | http://gition.local | 백엔드 기본 URL |
| `FRONTEND_URL` | http://gition.local | 프론트엔드 URL (OAuth 리다이렉트) |
| `ALLOWED_ORIGINS` | http://gition.local,http://127.0.0.1,http://localhost | CORS 허용 Origins |
| `REPOS_PATH` | /repos | Git 저장소 경로 (공유 볼륨) |

### GitHub OAuth

| 변수명 | 값 | 설명 |
|------|-----|------|
| `GITHUB_CLIENT_ID` | Secret 참조 | `github-secret.client-id` |
| `GITHUB_CLIENT_SECRET` | Secret 참조 | `github-secret.client-secret` |

## 리소스 제한

| 항목 | Requests | Limits |
|------|----------|--------|
| CPU | 100m | 500m |
| Memory | 128Mi | 512Mi |

## Health Check

| Probe | Path | Initial Delay | Period |
|-------|------|---------------|--------|
| Liveness | `/health` | 30s | 60s |
| Readiness | `/health` | 15s | 60s |

## 배포 관련 

### 배포 명령어
```bash
kubectl apply -f fastapi-deployment.yaml
kubectl get pods -n gition -l app=api
```

### 새 이미지가 배포 하는 경우
```bash
# k8s-m에서 실행
kubectl rollout restart deployment/api -n gition
# 상태 확인
kubectl rollout status deployment/api -n gition
#결과 : deployment "api" successfully rolled out
```