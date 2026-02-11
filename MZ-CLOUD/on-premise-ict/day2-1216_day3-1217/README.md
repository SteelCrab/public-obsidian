# 🔧 Day 2-3: FastAPI 3-Tier Application

FastAPI + MySQL을 사용한 3-Tier 아키텍처 + GitLab/GitHub CI/CD

> 📊 **[아키텍처 다이어그램 보기](./ARCHITECTURE.md)** - Mermaid 다이어그램으로 전체 구성 확인

---

## 📑 목차

1. [🔄 GitHub → GitLab 미러링](#-github--gitlab-자동-미러링-설정)
2. [🦊 GitLab CI/CD](#-gitlab-cicd)
3. [🚀 Kubernetes 배포](#-kubernetes-배포)
4. [🗄️ 3-Tier 아키텍처](#️-3-tier-아키텍처)
5. [📝 API 엔드포인트](#-api-엔드포인트)
6. [🔧 환경변수 설정](#-환경변수-설정)
7. [🔥 트러블슈팅](#-트러블슈팅)

---

## 🔄 GitHub → GitLab 자동 미러링 설정

> GitHub Actions를 통해 자동으로 GitLab에 동기화

### 설정 단계

| Step | 작업 | 상세 |
|------|------|------|
| **1** | GitLab 빈 프로젝트 생성 | GitLab > New project > Create blank project |
| **2** | Access Token 발급 | Settings > Access Tokens (`write_repository` 체크) |
| **3** | GitHub Secrets 설정 | Settings > Secrets and variables > Actions |

### 🔐 GitHub Secrets

| Secret 이름 | 값 |
|------------|-----|
| `GITLAB_URL` | `gitlab.com/username/pista-megazoncloud.git` |
| `GITLAB_TOKEN` | Step 2에서 발급한 토큰 |

> **워크플로우 파일**: `.github/workflows/mirror-to-gitlab.yml`
> `main`, `feat/**`, `kubernetes` 브랜치 푸시 시 자동 미러링

---

## 🦊 GitLab CI/CD

`.gitlab-ci.yml`이 포함되어 있어 `main` 또는 `feat/On-premise-ICT` 브랜치에 푸시하면 자동으로:

| 순서 | 작업 | 결과물 |
|------|------|--------|
| 1 | Docker 이미지 빌드 | - |
| 2 | GitLab Container Registry 푸시 | `$CI_REGISTRY_IMAGE/fastapi:latest` |
| 3 | - | `$CI_REGISTRY_IMAGE/nginx:latest` |
| 4 | - | `$CI_REGISTRY_IMAGE/mysql:latest` |

### 🔐 로컬에서 GitLab Registry 로그인

```bash
docker login registry.gitlab.com
# Username: GitLab 사용자명
# Password: Personal Access Token (비밀번호 아님!)
```

**Personal Access Token 발급:**
1. GitLab → 우측 상단 프로필 → **Edit profile**
2. **Access Tokens** 메뉴
3. Scopes: `read_registry`, `write_registry` 체크
4. **Create personal access token** → 토큰 복사

---

## 🚀 Kubernetes 배포

### 1️⃣ GitLab Registry Secret 생성

```bash
kubectl create secret docker-registry gitlab-registry-secret \
  --docker-server=registry.gitlab.com \
  --docker-username=pyh5523 \
  --docker-password=<Personal Access Token>
```

> [!WARNING]
> **ImagePullBackOff 에러 발생 시:**
> - Secret 확인: `kubectl get secrets`
> - Pod 재생성: `kubectl delete pod -l app=fastapi-pod`
> - `imagePullSecrets` 설정 확인

### 2️⃣ 애플리케이션 배포

```bash
# FastAPI 배포
kubectl apply -f fastapi-deploy.yaml
kubectl apply -f fastapi-service.yaml

# Nginx 배포
kubectl apply -f ../nginx/nginx-deploy.yaml
kubectl apply -f ../nginx/nginx-service.yaml
```

### 3️⃣ MySQL 배포

```bash
# ConfigMap (초기화 스크립트)
kubectl apply -f mysql/mysql-configmap.yaml

# Secret/PV/PVC (⚠️ Secret 값은 직접 수정 후 적용!)
kubectl apply -f mysql/mysql-secret.yaml
kubectl apply -f mysql/mysql-pv.yaml
kubectl apply -f mysql/mysql-pvc.yaml
kubectl apply -f mysql/mysql-deploy.yaml
kubectl apply -f mysql/mysql-service.yaml
```

### 4️⃣ 배포 확인

```bash
kubectl get pods
kubectl get svc
kubectl get pv,pvc
```

---

## 🗄️ 3-Tier 아키텍처

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Nginx     │────▶│   FastAPI   │────▶│   MySQL     │
│   (Web)     │     │   (WAS)     │     │   (DB)      │
│  Port 80    │     │  Port 8000  │     │  Port 3306  │
└─────────────┘     └─────────────┘     └─────────────┘
     /member    proxy    /member     pymysql
```

---

## 📝 API 엔드포인트

| Method | Path | 설명 |
|--------|------|------|
| GET | `/` | Hello World 응답 |
| GET | `/member` | MySQL 연결 테스트 |

---

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

---

## ⚙️ 환경 설정

| 항목 | 값 |
|------|-----|
| **Port** | 8000 |
| **CORS** | localhost:8000, example.com |
| **Python** | 3.12-slim |

---

## 🔥 트러블슈팅

### MySQL ConfigMap init.sql이 실행되지 않음

**증상:**
```json
{"message":"fail","error":"(1146, \"Table 'pista-db.tmember' doesn't exist\")"}
```

**원인:**
- MySQL 초기화 스크립트는 **데이터 디렉토리가 비어있을 때만** 실행됨
- PVC에 이전 데이터가 남아있으면 init.sql이 무시됨

**해결:**
```bash
# 1. 모든 노드에서 데이터 삭제
ssh k8s-n1 "sudo rm -rf /data/mysql/*"
ssh k8s-n2 "sudo rm -rf /data/mysql/*"
ssh k8s-n3 "sudo rm -rf /data/mysql/*"
kubectl delete -f mysql/

# 2. MySQL 리소스 재배포
kubectl apply -f mysql/
```

**검증:**
```bash
curl 192.168.5.101:8000/member
# {"message":"success","data":[...]}
```
