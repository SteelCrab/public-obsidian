# Day 9 - K8s 배포 및 Ingress 구조 개선 (01/05)

> GitLab Registry 연동, Ingress 기반 라우팅, GitHub OAuth 설정

## 목차

1. [📋 개요](#-개요)
2. [🏗️ 아키텍처](#-아키텍처)
3. [🐳 Registry 접근 테스트](#-registry-접근-테스트)
4. [🔄 CI/CD 파이프라인](#-cicd-파이프라인)
5. [☸️ K8s 배포](#-k8s-배포)
6. [🌐 브라우저 접속](#-브라우저-접속)
7. [🔧 트러블슈팅](#-트러블슈팅)
   - [1~3. Runner/Registry/DNS](#1-runner에서-gitlab-접근-불가)
   - [4~7. Nginx/MySQL/OAuth](#4-nginx-upstream-auth-backend-not-found)
   - [8~9. Secret/Encoding](#8-git-history-secret-leakage-secret-scrubbing)
   - [10~13. Branch Notes 관련](#10-repository-not-cloned-저장소-불일치)
8. [📚 참고](#-참고)

---

## 📋 개요

### 오늘 작업 내용

| 작업 | 상태 |
|------|------|
| GitLab Registry 연결 테스트 | ✅ |
| CI/CD 파이프라인 실행 | ✅ |
| containerd insecure registry 설정 | ✅ |
| 외부 MySQL 연결 (Endpoints) | ✅ |
| Ingress 기반 라우팅 구조 변경 | ✅ |
| ConfigMap으로 nginx 설정 분리 | ✅ |
| NodePort 30080 고정 | ✅ |
| GitHub OAuth 로그인 구현 | ✅ |
| 브라우저 접속 확인 | ✅ |
| NFS 공유 저장소 (PVC) 구성 | ✅ |
| MySQL Master-Slave Replication 자동화 | ✅ |
| Branch Notes 기능 정상화 | ✅ |

---

## 🏗️ 아키텍처

```
                    외부 인터넷 (gition.local)
                               │                     SSH Tunnel (8080 -> 80)
                               ▼                              │
                ┌────────────────────────────────────────────────────────┐
                │ Ingress Controller Service (NodePort)                  │
                │  NodePort: 30080                                       │
                │  ExternalIP: 172.100.100.20                            │
                └────────────────────────────────────────────────────────┘
                               │
                               ▼
                ┌────────────────────────────────────────────────────────┐
                │ Ingress (gition-ingress)                               │
                └────────────────────────────────────────────────────────┘
                       │    │    │          /api/*       │    │    │ /* (catch-all)
          /auth/github │    │    │ /auth/callback
                       ▼    │    ▼               ┌───────────────────────┐
               ┌───────────────────────┐         │ frontend-svc          │
               │ api-svc               │         │ :80                   │
               │ :3001                 │         └───────────────────────┘
               └───────────────────────┘               │    │        │
                       │    │        │                 │    │        │
               ┌───────────────────────┐               │  Frontend   │
               │  API (FastAPI)        │               │(nginx+React)│
               │                       │               └───────────────────────┘
               └───────────────────────┘
                            │
                            ▼
               ┌───────────────────────────────┐
               │    mysql-master (외부 VM)     │
               │    172.100.100.11:3306        │
               │    (ClusterIP + Endpoints)    │
               └───────────────────────────────┘
```

---

## 🐳 Registry 접근 테스트
```bash
docker login 172.100.100.8:5050
docker pull 172.100.100.8:5050/root/gition/backend:latest
docker pull 172.100.100.8:5050/root/gition/frontend:latest
```

---

## 🔄 CI/CD 파이프라인
### GitLab Runner 설정

```toml
# /etc/gitlab-runner/config.toml
[[runners]]
  name = "docker-runner"
  url = "http://172.100.100.8"
  clone_url = "http://172.100.100.8"
  
  [runners.docker]
    network_mode = "host"
    privileged = true
    volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
```

### BuildKit Provenance 비활성화

```yaml
build-backend:
  script:
    - docker build --provenance=false -t $CI_REGISTRY_IMAGE/backend:latest ./backend
```

---

## ☸️ K8s 배포

### 배포 파일 구조

| 파일 | 역할 |
|------|------|
| `frontend.yaml` | Frontend + ConfigMap + Service |
| `fastapi-deployment.yaml` | Backend API + Service + OAuth 환경변수 |
| `ingress.yaml` | 라우팅 규칙 (`/auth/github` 등 API, `/*` 등 Frontend) |
| `ingress-nginx-svc.yaml` | NodePort 30080 고정 |
| `mysql-master-svc.yaml` | 외부 MySQL 연결 |

### Secret 생성

```bash
# GitHub OAuth
kubectl create secret generic github-secret \
  --from-literal=client-id='<GITHUB_CLIENT_ID>' \
  --from-literal=client-secret='<GITHUB_CLIENT_SECRET>' \
  -n gition

# MySQL
kubectl create secret generic mysql-secret \
  --from-literal=user-password='pista' \
  -n gition
```

### 배포 순서

```bash
# 1. Ingress Controller NodePort 고정
kubectl apply -f ingress-nginx-svc.yaml

# 2. 앱 배포
kubectl apply -f frontend.yaml
kubectl apply -f fastapi-deployment.yaml
kubectl apply -f mysql-master-svc.yaml

# 3. Ingress 배포
kubectl apply -f ingress.yaml

# 4. 확인
kubectl get pods,svc -n gition
kubectl get ingress -n gition
```

---

## 🌐 브라우저 접속

### 1. Windows hosts 파일 수정 (관리자 권한)

```
# C:\Windows\System32\drivers\etc\hosts
127.0.0.1  gition.local
```

### 2. SSH 터널 (Bastion 경유)

```bash
ssh -L 8080:172.100.100.20:80 -J pista@192.168.5.9 pista@172.100.100.12
```

### 3. 브라우저 접속

```
http://gition.local:8080
```

### GitHub OAuth 설정

GitHub Developer Settings에서 OAuth App 설정:
- **Homepage URL**: `http://gition.local:8080`
- **Callback URL**: `http://gition.local:8080/auth/github/callback`

---

## 🔧 트러블슈팅
### 1. Runner에서 GitLab 접근 불가

**에러:** `Could not connect to server`

**해결:** `config.toml`에 `clone_url`, `network_mode = "host"` 추가

---

### 2. K8s에서 HTTP Registry 접근 불가

**에러:** `http: server gave HTTP response to HTTPS client`

**해결:** containerd 설정

```bash
sudo mkdir -p /etc/containerd/certs.d/172.100.100.8:5050
sudo tee /etc/containerd/certs.d/172.100.100.8:5050/hosts.toml > /dev/null <<EOF
server = "http://172.100.100.8:5050"

[host."http://172.100.100.8:5050"]
  capabilities = ["pull", "resolve", "push"]
  skip_verify = true
EOF
sudo systemctl restart containerd
```

---

### 3. ExternalName 서비스 DNS 해석 불가

**원인:** ExternalName은 IP 주소를 지원하지 않음
**해결:** ClusterIP + Endpoints 사용 (mysql-master-svc.yaml)

---

### 4. nginx upstream "auth-backend" not found

**원인:** 기존 nginx가 backend 목록을 설정 못함

**해결:** 
- Ingress가 라우팅 담당
- ConfigMap으로 nginx 설정 오버라이드 (정적 파일만 서빙)

---

### 5. Pod에서 외부 MySQL 연결 Timeout

**에러:** `Can't connect to MySQL server on 'mysql-master'`

**원인:** Docker 컨테이너와 iptables 규칙 꼬임 (UFW와 충돌)

**해결:**

```bash
# MySQL VM (172.100.100.11)에서
sudo ufw disable
sudo systemctl restart docker
```

---

### 6. GitHub OAuth redirect_uri 불일치
**에러:** `The redirect_uri is not associated with this application`

**원인:** SSH 터널 포트(8080)와 GitHub App 설정(80) 불일치
**해결:** GitHub OAuth App 설정에서 Callback URL을 SSH 터널 포트와 일치시킴
- `http://gition.local:8080/auth/github/callback`

---

### 7. OAuth 콜백 후 Not Found (404)

**에러:** `http://gition.local/auth/callback?user=...` 에서 404

**원인:** Ingress가 `/auth/*`를 모두 백엔드로 라우팅
**해결:** `ingress.yaml`에서 `/auth` 대신 `/auth/github`로 변경
- `/auth/github/*` 은 백엔드 (OAuth 처리)
- `/auth/callback` 은 프론트엔드 (catch-all로 전달)

---

## 📚 참고

- [Day 8 - GitLab 서버 이전](../day8-0104/README.md)
- [k8s/frontend.md](./k8s/frontend.md) - Frontend 배포 문서
- [k8s/ingress.md](./k8s/ingress.md) - Ingress 설정 문서
- [k8s/ingress-nginx-svc.md](./k8s/ingress-nginx-svc.md) - NodePort 고정 문서
- [k8s/fastapi-deployment.md](./k8s/fastapi-deployment.md) - Backend 배포 문서

---

### 8. Git History Secret Leakage (Secret Scrubbing)

**문제:** `.env.example` 및 K8s Manifest 파일에 하드코딩된 비밀번호(`***REMOVED***`)가 Git History에 남아있음 (GitGuardian 경고).

**해결:** BFG Repo-Cleaner를 사용하여 히스토리 전체에서 비밀번호 제거.

```bash
# 1. BFG로 히스토리 정제 (***REMOVED*** -> <REDACTED_PASSWORD>)
java -jar bfg.jar --replace-text replacements.txt .

# 2. 잔여 객체 정리 및 강제 푸시
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

---

### 9. File Encoding Issues (Mojibake)

**문제:** Windows(EUC-KR)와 Linux/Git(UTF-8) 환경 차이로 인해 한글 주석이 깨짐 (`???` 등으로 표시).

**해결:** 깨진 파일을 식별하고 UTF-8 인코딩으로 내용을 복원하여 재작성.

- **대상 파일:** `k8s/frontend.yaml`, `k8s/ingress.yaml`, `k8s/nfs-provisioner.yaml` 및 Markdown 문서들.
- **조치:** 원래의 한글 주석 내용을 유추하여 복구 완료.

---

### 10. Repository not cloned (저장소 불일치)

**에러:**
```
Repository not cloned
```

**원인:** `replicas: 3` 설정으로 백엔드 Pod 3개가 각자 로컬 볼륨 사용 → Clone된 저장소가 공유되지 않음

**해결:** NFS 기반 PVC 생성 및 볼륨 마운트 추가

```yaml
# fastapi-deployment.yaml
spec:
  template:
    spec:
      containers:
      - name: api
        volumeMounts:
        - name: repos-volume
          mountPath: /repos
      volumes:
      - name: repos-volume
        persistentVolumeClaim:
          claimName: repos-pvc
```

```bash
kubectl apply -f fastapi-deployment.yaml
```

---

### 11. 🐢 Failed to load page (DB 복제 실패)

**에러:**
```
Replica_IO_Running: Connecting
Last_IO_Error: error connecting to master 'repl_pista@172.100.100.11:3306'
```

**원인:** Master DB에 복제용 계정(`repl_pista`)이 존재하지 않음

**해결:**

1. Master에 복제 계정 생성:
```sql
-- docker/mysql-master/initdb.d/replication.sql
CREATE USER IF NOT EXISTS 'repl_pista'@'%' IDENTIFIED BY '<REPL_PASSWORD>';
GRANT REPLICATION SLAVE ON *.* TO 'repl_pista'@'%';
FLUSH PRIVILEGES;
```

2. Slave에 자동 복제 Sidecar 추가 (`mysql-slave.yaml`)

```bash
# 적용
docker exec mysql-master bash -c "mysql -uroot -p\$MYSQL_ROOT_PASSWORD < /docker-entrypoint-initdb.d/replication.sql"
kubectl delete pod -n gition -l app=mysql,role=slave
```

---

### 12. 🕳️ Schema Missing (텅 빈 DB)

**에러:**
```sql
mysql> SHOW TABLES;
-- Empty set (테이블 없음)
```

**원인:** GTID 복제는 연결 시점 이후의 변경만 동기화 → 기존 테이블/데이터 미전송

**해결:** `mysqldump`로 Master 스키마를 Slave에 수동 적용

```bash
kubectl exec -it mysql-slave-0 -n gition -c mysql -- bash -c \
  "mysqldump -h 172.100.100.11 -uroot -p<PASSWORD> \
   --single-transaction --set-gtid-purged=OFF gition \
   | mysql -uroot -p<PASSWORD> gition"
```

**검증:**
```bash
kubectl exec mysql-slave-0 -n gition -c mysql -- \
  mysql -uroot -p<PASSWORD> -e "USE gition; SHOW TABLES;"
# 결과: users, repositories, sessions, documents, branch_pages, pipelines
```

---

### 13. 🌐 DNS Crash (이름 해석 불가)

**에러:**
```
RuntimeError: Read database pool not initialized. Call init_pool() first.
mysqldump: Got error: 2005: Unknown MySQL server host 'mysql-master' (-2)
```

**원인:** K8s 내부 DNS가 `mysql-master` 서비스명을 IP로 변환 실패 → 앱 크래시

**해결:** `fastapi-deployment.yaml`에서 호스트명 대신 IP 직접 지정

```yaml
# 변경 전
- name: MYSQL_READ_HOST
  value: "mysql-read"
- name: MYSQL_WRITE_HOST
  value: "mysql-master"

# 변경 후
- name: MYSQL_READ_HOST
  value: "172.100.100.11"
- name: MYSQL_WRITE_HOST
  value: "172.100.100.11"
```

```bash
kubectl apply -f fastapi-deployment.yaml
kubectl delete pod -n gition -l app=api
```

---

### ✅ 최종 상태

| 항목 | 상태 |
|------|------|
| Branch Notes 로딩 | ✅ 정상 |
| MySQL Replication | ✅ `Replica_IO_Running: Yes` |
| 공유 저장소 (PVC) | ✅ 3개 Pod 동일 데이터 |
| DB 연결 | ✅ IP 직접 연결 |
