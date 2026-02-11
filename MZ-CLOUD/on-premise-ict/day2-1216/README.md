# FastAPI 3-Tier Application

FastAPI + MySQL을 사용한 3-Tier 아키텍처 + GitLab/GitHub CI/CD

> 📊 **[아키텍처 다이어그램 보기](./ARCHITECTURE.md)** - Mermaid 다이어그램으로 전체 구성 확인


### 1. GitHub → GitLab 자동 미러링 설정
> GitHub Actions를 통해 자동으로 GitLab에 동기화

**Step 1.** GitLab에서 빈 프로젝트 생성
- 경로: GitLab > New project > Create blank project
- 프로젝트명: `pista-megazoncloud`

**Step 2.** GitLab Project Access Token 발급
- 경로: GitLab > 해당 프로젝트 > Settings > Access Tokens
- Scopes: `write_repository` 체크

**Step 3.** GitHub Secrets 설정
- 경로: GitHub > Settings > Secrets and variables > Actions

| Secret 이름 | 값 |
|------------|-----|
| `GITLAB_URL` | `gitlab.com/username/pista-megazoncloud.git` |
| `GITLAB_TOKEN` | Step 2에서 발급한 토큰 |

**워크플로우 파일**: `.github/workflows/mirror-to-gitlab.yml`
- `main`, `feat/**`, `kubernetes` 브랜치 푸시 시 자동으로 GitLab에 미러링

## 🔄 GitLab CI/CD

`.gitlab-ci.yml`이 포함되어 있어 `main` 또는 `feat/On-premise-ICT` 브랜치에 푸시하면 자동으로:

1. Docker 이미지 빌드
2. GitLab Container Registry에 푸시
   - `$CI_REGISTRY_IMAGE/fastapi:latest`
   - `$CI_REGISTRY_IMAGE/nginx:latest`
   - `$CI_REGISTRY_IMAGE/mysql:latest`

### 🔐 로컬에서 GitLab Registry 로그인

```bash
docker login registry.gitlab.com
# Username: GitLab 사용자명
# Password: Personal Access Token (비밀번호 아님!)
```

**Personal Access Token 발급 방법:**
1. GitLab → 우측 상단 프로필 → **Edit profile**
2. **Access Tokens** 메뉴
3. Scopes: `read_registry`, `write_registry` 체크
4. **Create personal access token** → 토큰 복사

### 🚀 Kubernetes 배포

**3-1.** GitLab Registry Secret 생성 (K8s 클러스터에서)
```bash
kubectl create secret docker-registry gitlab-registry-secret \
  --docker-server=registry.gitlab.com \
  --docker-username=pyh5523 \
  --docker-password=<Personal Access Token>
```

> ⚠️ **ImagePullBackOff 에러 발생 시:**
> - Secret이 정상 생성되었는지 확인: `kubectl get secrets`
> - 기존 Pod 삭제 후 재생성: `kubectl delete pod -l app=fastapi-pod`
> - Deployment에 `imagePullSecrets` 설정이 있는지 확인

**3-2.** 이미지 Pull 및 배포
```bash
# FastAPI 배포
kubectl apply -f fastapi-deploy.yaml
kubectl apply -f fastapi-service.yaml

# Nginx 배포
kubectl apply -f ../nginx/nginx-deploy.yaml
kubectl apply -f ../nginx/nginx-service.yaml
```

**3-3.** MySQL 배포
```bash
# MySQL Secret/PV/PVC 적용 (⚠️ Secret 값은 직접 수정 후 적용!)
kubectl apply -f mysql/mysql-secret.yaml
kubectl apply -f mysql/mysql-pv.yaml
kubectl apply -f mysql/mysql-pvc.yaml
kubectl apply -f mysql/mysql-deploy.yaml
kubectl apply -f mysql/mysql-service.yaml
```

**3-4.** 배포 확인
```bash
kubectl get pods
kubectl get svc
kubectl get pv,pvc
```

## 🗄️ 3-Tier 아키텍처

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Nginx     │────▶│   FastAPI   │────▶│   MySQL     │
│   (Web)     │     │   (WAS)     │     │   (DB)      │
│  Port 80    │     │  Port 8000  │     │  Port 3306  │
└─────────────┘     └─────────────┘     └─────────────┘
     /member    proxy    /member     pymysql
```

## 📝 API 엔드포인트

| Method | Path | 설명 |
|--------|------|------|
| GET | `/` | Hello World 응답 |
| GET | `/member` | MySQL 연결 테스트 |

## 🔧 환경변수 설정

| 변수명 | 기본값 | 설명 |
|--------|--------|------|
| `MYSQL_HOST` | `mysql` | MySQL 호스트 |
| `MYSQL_USER` | `root` | MySQL 사용자 |
| `MYSQL_PASSWORD` | `root` | MySQL 비밀번호 |
| `MYSQL_DB` | `test` | 데이터베이스명 |

**Kubernetes에서 환경변수 설정:**
```yaml
env:
  - name: MYSQL_HOST
    value: "mysql-service"
  - name: MYSQL_USER
    valueFrom:
      secretKeyRef:
        name: mysql-secret
        key: username
```

## ⚙️ 환경 설정

- **Port**: 8000
- **CORS**: localhost:8000, example.com 허용
- **Python**: 3.12-slim 기반
