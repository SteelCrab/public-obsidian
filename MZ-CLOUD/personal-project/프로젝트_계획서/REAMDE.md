# 프로젝트 계획서

> Git + Notion = **Gition**
> 개발자를 위한 올인원 협업 플랫폼

---

## 1. 프로젝트 주제

### 1.1. 주 주제

**Git 저장소와 블록 기반 문서를 통합한 개발자 협업 플랫폼 구축**

### 1.2. 세부 주제

| 구분 | 내용 |
|------|------|
| **코드 관리** | GitHub 연동, 브랜치/커밋 관리 |
| **문서화** | Notion 스타일 블록 에디터 |
| **CI/CD** | GitHub Actions + GitLab CI 하이브리드 |
| **인증** | GitHub OAuth 2.0 |

---

## 2. 요구사항 정의

### 2.1. 기능 요구사항

#### 2.1.1. 인증 및 계정 관리

| 기능 | 구현 방식 | 상태 |
|------|----------|------|
| **GitHub OAuth** | OAuth 2.0 | O |
| **세션 관리** | Token 기반 | O |
| **로그인/로그아웃** | localStorage 저장 | O |

#### 2.1.2. 저장소 관리

| 기능 | 설명 | 상태 |
|------|------|------|
| **저장소 목록** | GitHub API 연동 | O |
| **저장소 복제** | 서버로 Clone | O |
| **브랜치 전환** | 로컬/리모트 브랜치 | O |
| **파일 탐색** | 디렉토리 네비게이션 | O |

#### 2.1.3. 에디터

| 기능 | 설명 | 상태 |
|------|------|------|
| **블록 에디터** | Notion 스타일 | O |
| **마크다운 렌더링** | MarkdownRenderer | - |
| **코드 블록** | 구문 강조 | - |
| **`.gition` 저장소** | 브랜치별 로컬 페이지 | O |

#### 2.1.4. Git 연동

| 기능 | 설명 | 상태 |
|------|------|------|
| **커밋 히스토리** | 브랜치별 조회 | O |
| **파일 뷰어** | 내용 조회/편집 | O |
| **코드 검색** | 저장소 내 검색 | O |
| **Issues/PR** | GitHub 연동 표시 | O |

#### 2.1.5. CI/CD 파이프라인

| 플랫폼 | 기능 | 상태 |
|--------|------|------|
| **GitHub Actions** | ESLint / PyLint 검사 | O |
| | Unit Test 실행 | O |
| | Gitleaks / Trivy 보안 스캔 | O |
| | GitLab Mirror 동기화 | O |
| **GitLab CI** | Docker 이미지 빌드 | O |
| | Container Registry 푸시 | O |
| | 수동 배포 트리거 | O |

#### 2.1.6. Kubernetes 인프라

| 구성 요소 | 설명 | 상태 |
|-----------|------|------|
| **Ingress Controller** | Host/Path 기반 라우팅 | O |
| **MetalLB** | LoadBalancer IP 할당 | O |
| **NFS Provisioner** | 동적 PVC 생성 | O |
| **FastAPI Deployment** | 3 replicas + 공유 볼륨 | O |
| **Frontend Deployment** | 2 replicas (React + Nginx) | O |
| **MySQL Master** | VM Docker (외부 Endpoints) | O |
| **MySQL Slave StatefulSet** | K8s 내 2 replicas (GTID 복제) | O |
| **imagePullSecrets** | GitLab Registry 인증 | O |

### 2.2. 비기능 요구사항

| 항목 | 요구사항 | 설명 |
|------|----------|------|
| **응답 시간** | API 응답 < 500ms | 사용자 경험 보장 |
| **가용성** | 99% 이상 | 연간 다운타임 87시간 이내 |
| **확장성** | K8s 기반 스케일 아웃 | HPA/VPA 자동 스케일링 |
| **보안** | OAuth 2.0 + Token 기반 | GitHub 인증 연동 |
| **유지보수성** | 모듈화 아키텍처 | 컴포넌트 단위 배포 가능 |

---

## 3. 프로젝트 목표

### 3.1. 핵심 목표

```
┌─────────────────────────────────────────────────────────────┐
│                    Gition 핵심 가치                          │
├─────────────────────────────────────────────────────────────┤
│  [통합]      코드 + 문서 + CI/CD를 하나의 플랫폼에           │
│  [버전관리]  Git 기반 문서 자동 버전 관리                    │
│  [실시간]    CI/CD 상태를 문서에서 실시간 확인               │
└─────────────────────────────────────────────────────────────┘
```

### 3.2. 마일스톤

| 버전 | 목표 | 진행률 |
|------|------|--------|
| **v0.1** | Core Platform | 85% |
| **v0.2** | Visualization & Features | 10% |
| **v0.3** | Advanced Integrations | 0% |

---

## 4. 시스템 아키텍처 설계

### 4.1. 전체 구성

```
┌─────────────────────────────────────────────────────────────┐
│                         Client                               │
│                    (React + Vite)                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│             Ingress Controller (nginx-ingress)               │
│                    Host: gition.local                        │
│                    /api/* → api-svc:3001                     │
│                    /*     → frontend-svc:80                  │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌─────────────────────────┐     ┌─────────────────────────────┐
│        FastAPI          │     │         React SPA           │
│   (Deployment: 3 pods)  │     │   (Deployment: replicas)    │
│                         │     │                             │
│  • GitHub OAuth         │     │  • 블록 에디터              │
│  • Git Operations       │     │  • 파일 브라우저            │
│  • Page CRUD            │     │  • 커밋 히스토리            │
│  • /repos NFS Mount     │     │                             │
└─────────────────────────┘     └─────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                     MySQL (Master-Slave)                     │
├──────────────────────────┬──────────────────────────────────┤
│   Master (VM Docker)     │      Slave (K8s StatefulSet)     │
│   172.100.100.11         │      mysql-slave-0, mysql-slave-1│
│   Write 전용             │      Read 전용 (GTID 복제)       │
│                          │                                  │
│  • Users                 │      • 자동 복제 설정            │
│  • Repositories          │      • server-id 자동 할당       │
│  • BranchPages           │                                  │
│  • Sessions              │                                  │
└──────────────────────────┴──────────────────────────────────┘
```

### 4.2. 기술 스택

| 계층 | 기술 |
|------|------|
| **Frontend** | React + Vite + TypeScript |
| **Backend** | Python FastAPI + GitPython |
| **Database** | MySQL 8.0 (Master-Slave Replication) |
| **Auth** | GitHub OAuth 2.0 |
| **Infra** | Kubernetes + MetalLB + NFS |
| **CI/CD** | GitHub Actions + GitLab CI |

### 4.3. Kubernetes 인프라 구성

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              Client (Browser)                                 │
│                         http://gition.local                                   │
└───────────────────────────────────┬───────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    LoadBalancer Service (MetalLB)                             │
│                    (ingress-nginx-controller)                                 │
│                                                                              │
│    externalIPs: 172.100.100.20:80                                            │
│    NodePort: 30080 (대체 경로)                                                │
└───────────────────────────────────┬───────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    Ingress Resource (gition-ingress)                          │
│                    Host: gition.local                                         │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   /api/*         ──────────►  api-svc:3001  ──────►  FastAPI Pods (x3)       │
│   /auth/github   ──────────►  api-svc:3001  ──────►  FastAPI Pods            │
│   /health        ──────────►  api-svc:3001  ──────►  FastAPI Pods            │
│   /* (catch-all) ──────────►  frontend-svc:80 ────►  React Pods              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 4.4. CI/CD 파이프라인

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CI/CD Pipeline                                  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────┐    ┌─────────────────────────────────────────────────────────┐
│   GitHub    │    │                   GitHub Actions                        │
│   (Public)  │    │                                                         │
│             │    │  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐  │
│  [Source]───┼───►│  │ ESLint  │──►│  Test   │──►│ Security│──►│ Mirror  │  │
│   Code      │    │  │ PyLint  │   │  Suite  │   │  Scan   │   │ Sync    │  │
│             │    │  └─────────┘   └─────────┘   └─────────┘   └────┬────┘  │
└─────────────┘    └─────────────────────────────────────────────────┼───────┘
                                                                     │
                                                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              GitLab (Private)                                │
│                                                                             │
│  ┌─────────────┐        ┌─────────────────┐        ┌─────────────────────┐  │
│  │   Docker    │───────►│   Container     │───────►│    Kubernetes       │  │
│  │   Build     │        │   Registry      │        │    Deployment       │  │
│  └─────────────┘        └─────────────────┘        └─────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### GitHub Actions (Public)
- ESLint / PyLint 검사
- Unit Test 실행
- Gitleaks / Trivy 보안 스캔
- GitLab Mirror 동기화

#### GitLab CI (Private)
- Docker 이미지 빌드
- Container Registry 푸시
- 수동 배포 트리거

---

## 5. 데이터베이스 설계

### 5.1. ERD

```
┌────────────────────┐
│       Users        │
├────────────────────┤
│ PK  id             │
│     github_id      │
│     login          │
│     email          │
│     avatar_url     │
│     access_token   │
│     created_at     │
│     updated_at     │
└─────────┬──────────┘
          │
          │ 1:N
          ▼
┌────────────────────┐         ┌────────────────────┐
│    Repositories    │         │      Sessions      │
├────────────────────┤         ├────────────────────┤
│ PK  id             │         │ PK  id             │
│ FK  user_id ───────┼─────────│ FK  user_id        │
│     github_id      │         │     token_hash     │
│     name           │         │     expires_at     │
│     full_name      │         │     created_at     │
│     owner          │         └────────────────────┘
│     clone_url      │
│     default_branch │
│     is_private     │
│     cloned_at      │
│     last_synced    │
└─────────┬──────────┘
          │
          │ 1:N
          ▼
┌────────────────────┐
│    BranchPages     │
├────────────────────┤
│ PK  id             │
│ FK  repo_id        │
│ FK  user_id        │
│     branch_name    │
│     title          │
│     content (JSON) │
│     created_at     │
│     updated_at     │
└────────────────────┘
```

### 5.2. 주요 테이블 상세

| 테이블 | 용도 | 주요 컬럼 |
|--------|------|----------|
| `users` | GitHub OAuth 사용자 정보 | github_id, login, access_token |
| `repositories` | 연동된 저장소 메타데이터 | github_id, clone_url, default_branch |
| `sessions` | 사용자 세션 관리 | token_hash, expires_at |
| `branch_pages` | 브랜치별 페이지 콘텐츠 | branch_name, content (JSON) |

### 5.3. 테이블 관계

| 관계 | 설명 |
|------|------|
| Users → Repositories | 1:N (사용자가 여러 저장소 보유) |
| Users → Sessions | 1:N (사용자가 여러 세션 생성 가능) |
| Repositories → BranchPages | 1:N (저장소별 브랜치 페이지) |
| Users → BranchPages | 1:N (사용자별 페이지 소유) |

### 5.4. MySQL 복제 구성

| 구성 요소 | 위치 | 역할 |
|-----------|------|------|
| **Master** | VM (172.100.100.11) Docker Compose | Write 전용 |
| **Slave (x2)** | K8s StatefulSet | Read 전용 (GTID 복제) |

---

## 6. 프로젝트 산출물

### 6.1. 구현 파일 목록

| 구분 | 파일 | 위치 |
|------|------|------|
| **Frontend** | `App.tsx` | `frontend/` |
| **Backend** | `main.py` | `backend/` |
| **DB** | `database.py` | `backend/` |
| **Git Ops** | `git_ops.py` | `backend/` |
| **CI/CD** | `pipelines.yaml` | `.github/workflows/` |
| **GitLab CI** | `.gitlab-ci.yml` | 프로젝트 루트 |
| **Docker** | `docker-compose.yml` | 프로젝트 루트 |

### 6.2. Kubernetes 매니페스트

| 구분 | 파일 | 설명 |
|------|------|------|
| **Ingress** | `ingress.yaml` | 라우팅 규칙 (Host/Path) |
| **LoadBalancer** | `ingress-nginx-svc.yaml` | MetalLB 외부 IP 설정 |
| **Backend** | `fastapi-deployment.yaml` | FastAPI Deployment + Service (Replicas: 3) |
| **Frontend** | `frontend.yaml` | React Deployment + Service |
| **Database** | `mysql-slave.yaml` | MySQL StatefulSet (Read Replicas) |
| **Storage** | `nfs-provisioner.yaml` | NFS 동적 프로비저닝 |
| **MetalLB** | `metallb-config.yaml` | IP Pool 설정 |

### 6.3. 주요 컴포넌트

| 컴포넌트 | 설명 | 파일 |
|----------|------|------|
| **FileTree** | 파일 탐색기 UI | `frontend/components/` |
| **BlockEditor** | 블록 에디터 | `frontend/components/` |
| **CommitHistory** | 커밋 히스토리 뷰 | `frontend/components/` |
| **MarkdownRenderer** | 마크다운 렌더링 | `frontend/components/` |

---

## 7. 일정 계획

| 단계 | 작업 내용 | 상태 |
|------|----------|------|
| **1단계** | OAuth + 저장소 연동 | O 완료 |
| **2단계** | 파일 브라우저 + 에디터 | O 완료 |
| **3단계** | 브랜치/커밋 관리 | O 완료 |
| **4단계** | 블록 에디터 고도화 | - 진행중 |
| **5단계** | CI/CD 시각화 | - 예정 |
| **6단계** | K8s 배포 | O 완료 |

---

## 8. 로드맵

### v0.1 Core Platform (85%)

| 기능 | 상태 | 설명 |
|------|------|------|
| GitHub OAuth 연동 | O | GitHub 로그인/로그아웃 |
| 저장소 목록/복제 | O | GitHub API 연동, 서버 Clone |
| 파일 브라우저 | O | 디렉토리 네비게이션 |
| 브랜치 관리 | O | 로컬/리모트 브랜치 전환 |
| 커밋 히스토리 | O | 브랜치별 조회 |
| 블록 에디터 기본 | O | Notion 스타일 |
| 마크다운 렌더링 | - | MarkdownRenderer 구현 예정 |
| 코드 블록 구문 강조 | - | Syntax Highlighting |
| 그래프 시각화 | - | D3.js 기반 |

### v0.2 Visualization & Features (10%)

| 기능 | 상태 | 설명 |
|------|------|------|
| 커밋 그래프 | - | 트리 구조 시각화 |
| Issue/PR 생성 | - | GitHub API 연동 |
| 웹 터미널 | - | xterm.js + WebSocket |
| 실시간 편집 | - | WebSocket 기반 동시 편집 |

### v0.3 Advanced Integrations (0%)

| 기능 | 상태 | 설명 |
|------|------|------|
| ArgoCD GitOps | - | 자동 배포 파이프라인 |
| Helm Chart | - | K8s 패키지 관리 |
| 멀티 클러스터 | - | 분산 배포 지원 |

### Infrastructure (완료)

| 기능 | 상태 | 설명 |
|------|------|------|
| Docker Compose 개발 환경 | O | 로컬 개발용 |
| GitHub Actions CI | O | 린트, 테스트, 보안 스캔 |
| GitLab CI/CD | O | 빌드, 레지스트리, 배포 |
| Kubernetes 배포 | O | 아래 상세 참조 |

#### Kubernetes 상세

| 구성 요소 | 상태 |
|-----------|------|
| Ingress Controller (nginx-ingress) | O |
| LoadBalancer (MetalLB + externalIPs) | O |
| NFS Provisioner (동적 PVC) | O |
| FastAPI Deployment (3 replicas, 공유 저장소) | O |
| Frontend Deployment | O |
| MySQL Master (VM Docker) | O |
| MySQL Slave StatefulSet (K8s, GTID 복제) | O |
| Read/Write Split (database.py) | O |

---

## 9. 트러블슈팅

### 9.1. CI/CD 관련

| Day | 문제 | 해결 |
|-----|------|------|
| 3 | Runner에서 GitLab 접근 불가 | `config.toml`에 `clone_url`, `network_mode = "host"` 추가 |
| 3 | HTTP Registry 오류 | `insecure-registries` 설정 |
| 9 | Git History Secret Leakage | BFG Repo-Cleaner |
| 11 | Docker 빌드 시 DNS 해석 실패 | Docker `daemon.json`에 DNS 추가 |

```bash
# insecure-registries (daemon.json)
{"insecure-registries": ["172.100.100.8:5050"], "dns": ["8.8.8.8"]}

# BFG로 비밀번호 제거
java -jar bfg.jar --replace-text replacements.txt .
git push --force
```

### 9.2. Kubernetes 관련

| Day | 문제 | 해결 |
|-----|------|------|
| 2 | PVC Pending | RBAC Role/RoleBinding 추가 |
| 2 | Readiness probe failed | `command: bash -c "..."` 사용 |
| 9 | Repository not cloned | NFS PVC 마운트 |
| 9 | nginx upstream not found | Ingress 라우팅으로 변경 |

```yaml
# NFS PVC 마운트 (fastapi-deployment.yaml)
volumes:
- name: repos-volume
  persistentVolumeClaim:
    claimName: repos-pvc
```

### 9.3. Database 관련

| Day | 문제 | 해결 |
|-----|------|------|
| 9 | MySQL 연결 불가 | `sudo ufw disable` + Docker 재시작 |
| 9 | Replication 실패 | Master에 복제 계정 생성 |
| 9 | Schema Missing | mysqldump로 수동 동기화 |
| 10 | Duplicate Key 에러 | Read/Write 모두 Master 사용 |
| 11 | MySQL 연결 Timeout | Docker 재시작 |

```bash
# MySQL 연결 복구
sudo systemctl restart docker

# 스키마 동기화
kubectl exec mysql-slave-0 -n gition -- bash -c \
  "mysqldump -h 172.100.100.11 -uroot -p<PW> --set-gtid-purged=OFF gition | mysql -uroot -p<PW> gition"
```

### 9.4. Network 관련

| Day | 문제 | 해결 |
|-----|------|------|
| 9 | ExternalName DNS 불가 | ClusterIP + Endpoints 사용 |
| 9 | OAuth redirect_uri 불일치 | Callback URL 포트 수정 |
| 9 | OAuth 콜백 후 404 | `/auth/github/*`만 백엔드로 변경 |

```yaml
# ClusterIP + Endpoints (mysql-master-svc.yaml)
apiVersion: v1
kind: Service
metadata:
  name: mysql-master
spec:
  ports:
  - port: 3306
---
apiVersion: v1
kind: Endpoints
metadata:
  name: mysql-master
subsets:
  - addresses:
      - ip: 172.100.100.11
    ports:
      - port: 3306
```

### 9.5. 참고 문서

| Day | 주제 | 주요 트러블슈팅 |
|-----|------|---------------|
| Day 2 | 3-Tier 배포 | PVC Pending, Readiness Probe |
| Day 3 | 외부 Registry 연동 | 2단계 포트포워딩, insecure-registries |
| Day 9 | K8s Ingress 구조 개선 | OAuth 라우팅, NFS PVC, MySQL Replication |
| Day 10 | Read/Write Split | 복제 지연, Duplicate Key |
| Day 11 | 빌드 DNS 오류 | Docker daemon.json DNS 설정 |