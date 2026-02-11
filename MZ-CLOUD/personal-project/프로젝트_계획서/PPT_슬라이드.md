# Gition 프로젝트 발표 자료

> 슬라이드별 복사/붙여넣기용 콘텐츠

---

## 슬라이드 1: 표지

### Gition
**Git + Notion = 개발자를 위한 올인원 협업 플랫폼**

- 발표자: [이름]
- 날짜: 2026년 1월

---

## 슬라이드 2: 프로젝트 개요

### 프로젝트 배경

| 문제점 | 기존 방식 | Gition 해결책 |
|--------|----------|---------------|
| 코드와 문서 분리 | GitHub + Notion 별도 사용 | 단일 워크스페이스 |
| 문서 버전 관리 없음 | 수동 백업 또는 없음 | Git 기반 자동 버전 관리 |
| CI/CD 상태 확인 | 탭 전환 필요 | 문서 내 실시간 표시 |

### 핵심 가치
- **통합**: 코드 + 문서 + CI/CD를 하나의 플랫폼에
- **버전관리**: Git 기반 문서 자동 버전 관리
- **실시간**: CI/CD 상태를 문서에서 실시간 확인

---

## 슬라이드 3: 기술 스택

### 아키텍처 개요

| 계층 | 기술 |
|------|------|
| **Frontend** | React + Vite + TypeScript |
| **Backend** | Python FastAPI + GitPython |
| **Database** | MySQL 8.0 (Master-Slave Replication) |
| **Auth** | GitHub OAuth 2.0 |
| **Infra** | Kubernetes + MetalLB + NFS |
| **CI/CD** | GitHub Actions + GitLab CI |

---

## 슬라이드 4: 기능 요구사항 (1)

### 인증 및 계정 관리

| 기능 | 구현 방식 | 상태 |
|------|----------|------|
| GitHub OAuth | OAuth 2.0 | O |
| 세션 관리 | Token 기반 | O |
| 로그인/로그아웃 | localStorage 저장 | O |

### 저장소 관리

| 기능 | 설명 | 상태 |
|------|------|------|
| 저장소 목록 | GitHub API 연동 | O |
| 저장소 복제 | 서버로 Clone | O |
| 브랜치 전환 | 로컬/리모트 브랜치 | O |
| 파일 탐색 | 디렉토리 네비게이션 | O |

---

## 슬라이드 5: 기능 요구사항 (2)

### 에디터

| 기능 | 설명 | 상태 |
|------|------|------|
| 블록 에디터 | Notion 스타일 | O |
| 마크다운 렌더링 | MarkdownRenderer | - |
| 코드 블록 | 구문 강조 | - |
| `.gition` 저장소 | 브랜치별 로컬 페이지 | O |

### Git 연동

| 기능 | 설명 | 상태 |
|------|------|------|
| 커밋 히스토리 | 브랜치별 조회 | O |
| 파일 뷰어 | 내용 조회/편집 | O |
| 코드 검색 | 저장소 내 검색 | O |
| Issues/PR | GitHub 연동 표시 | O |

---

## 슬라이드 6: 비기능 요구사항

| 항목 | 요구사항 | 설명 |
|------|----------|------|
| **응답 시간** | < 500ms | 사용자 경험 보장 |
| **가용성** | 99% 이상 | 연간 다운타임 87시간 이내 |
| **확장성** | K8s 스케일 아웃 | HPA/VPA 자동 스케일링 |
| **보안** | OAuth 2.0 + Token | GitHub 인증 연동 |
| **유지보수성** | 모듈화 아키텍처 | 컴포넌트 단위 배포 |

---

## 슬라이드 7: 시스템 아키텍처

### 전체 흐름

```
Client (React) 
    ↓
Ingress Controller (nginx-ingress)
    ↓
┌─────────────────┬─────────────────┐
│  FastAPI (x3)   │   React SPA     │
│  /api, /auth    │   /* (정적)     │
└─────────────────┴─────────────────┘
         ↓
MySQL (Master-Slave)
```

### 주요 구성
- **Frontend**: React + Vite (정적 파일 서빙)
- **Backend**: FastAPI 3개 Pod (NFS 공유 저장소)
- **Database**: VM Master + K8s Slave (GTID 복제)

---

## 슬라이드 8: 인프라 구성

### Kubernetes 클러스터

| 구성 요소 | 설명 |
|-----------|------|
| MetalLB | LoadBalancer IP 할당 (172.100.100.20) |
| Ingress | Host/Path 기반 라우팅 |
| NFS Provisioner | 동적 PVC 생성 |
| StatefulSet | MySQL Slave (2 replicas) |

### CI/CD 파이프라인

```
GitHub → GitHub Actions (Lint/Test/Scan)
           ↓
       GitLab Mirror
           ↓
GitLab CI (Build/Push) → Container Registry
           ↓
       Kubernetes Deploy
```

---

## 슬라이드 9: 로드맵 - v0.1 Core Platform (85%)

| 기능 | 상태 | 설명 |
|------|:----:|------|
| GitHub OAuth 연동 | O | 로그인/로그아웃 |
| 저장소 목록/복제 | O | GitHub API, Clone |
| 파일 브라우저 | O | 네비게이션 |
| 브랜치 관리 | O | 전환 기능 |
| 커밋 히스토리 | O | 브랜치별 조회 |
| 블록 에디터 | O | Notion 스타일 |
| 마크다운 렌더링 | △ | 대부분 구현 |
| 코드 블록 구문 강조 | - | Syntax Highlighting |

---

## 슬라이드 10: 로드맵 - v0.2 & v0.3

### v0.2 Visualization & Features (10%)

| 기능 | 상태 |
|------|:----:|
| 커밋 그래프 | - |
| Issue/PR 생성 | - |
| 웹 터미널 | - |
| 실시간 편집 | - |

### v0.3 Advanced Integrations (0%)

| 기능 | 상태 |
|------|:----:|
| ArgoCD GitOps | - |
| Helm Chart | - |
| 멀티 클러스터 | - |

---

## 슬라이드 11: Infrastructure 완료 현황

| 구성 요소 | 상태 |
|-----------|:----:|
| Docker Compose 개발 환경 | O |
| GitHub Actions CI | O |
| GitLab CI/CD | O |
| Ingress Controller | O |
| LoadBalancer (MetalLB) | O |
| NFS Provisioner | O |
| FastAPI Deployment (3 replicas) | O |
| Frontend Deployment | O |
| MySQL Master (VM Docker) | O |
| MySQL Slave StatefulSet | O |
| Read/Write Split | O |

---

## 슬라이드 11.5: Day별 작업 진행 현황

| Day | 날짜 | 주요 작업 | 산출물 |
|:---:|------|----------|--------|
| **Day 1** | 12/24 | K8s 클러스터 초기 구축 | kubeadm, Calico CNI 설치 |
| **Day 2** | 12/29 | 기본 인프라 구성 | NFS, Docker, K8s manifests |
| **Day 3** | 12/30 | GitLab CI/CD 구축 | Runner 설정, .gitlab-ci.yml |
| **Day 4** | 12/31 | Container Registry 연동 | insecure-registry 설정 |
| **Day 5** | 01/01 | Frontend/Backend 배포 | Deployment, Ingress |
| **Day 6** | 01/02 | MySQL Master-Slave 구성 | ExternalName → Endpoints 전환 |
| **Day 7** | 01/03 | Replication 설정 | GTID 복제, server-id 자동화 |
| **Day 8** | 01/04 | 고가용성 테스트 | Failover 검증 |
| **Day 9** | 01/05 | OAuth/DB 트러블슈팅 | UFW, 복제 계정 생성 |
| **Day 10** | 01/06 | Read/Write Split | 복제 지연 대응 |
| **Day 11** | 01/07 | MetalLB 설정, 문서 정리 | LoadBalancer IP 할당 |
| **Day 12** | 01/08 | **MySQL InnoDB Cluster** | Operator, Local PV, Backup CronJob |

### Day 12 상세 (MySQL InnoDB Cluster)

| 구성 요소 | 설명 |
|----------|------|
| MySQL Operator | Helm 설치, 자동 Failover/복구 |
| InnoDBCluster CR | 3 MySQL + 2 Router |
| Local PV | 노드별 로컬 스토리지 (고성능) |
| NFS Backup | CronJob 매일 02:00 mysqldump |

---

## 슬라이드 12: 트러블슈팅 - CI/CD

### ⭐ Day 3: Runner에서 GitLab 접근 불가
- **상황**: GitLab CI 파이프라인 시작 시 Runner가 소스 코드를 Clone 하지 못함
- **에러**: `Could not connect to server`
- **원인**: Runner가 GitLab 내부 URL을 해석 못함 (Docker 네트워크 격리)
- **해결**: `/etc/gitlab-runner/config.toml` 수정
```toml
clone_url = "http://172.100.100.8"
network_mode = "host"
```

### Day 4: Docker API 버전 오류
- **상황**: GitLab CI에서 Docker 빌드 Job 실행 시 즉시 실패
- **에러**: `client version 1.43 is too old. Minimum supported API version is 1.44`
- **원인**: CI Job의 Docker 클라이언트 이미지와 Runner의 Docker daemon 버전 불일치
- **해결**: `.gitlab-ci.yml`에서 Docker 이미지 업그레이드
```yaml
image: docker:27  # 24.0.5 → 27
```

### Day 11: Docker 빌드 시 DNS 해석 실패
- **상황**: `docker build` 중 `pip install` 또는 `npm install`에서 외부 패키지 다운로드 실패
- **에러**: `Temporary failure in name resolution`
- **원인**: 빌드 컨테이너가 외부 DNS 해석 불가 (pypi.org, registry.npmjs.org 접근 필요)
- **해결**: `/etc/docker/daemon.json`에 Google DNS 추가
```json
{"insecure-registries": ["172.100.100.8:5050"], "dns": ["8.8.8.8", "8.8.4.4"]}
```

---

## 슬라이드 13: 트러블슈팅 - Kubernetes

### ⭐ Day 4: HTTP Registry → HTTPS 오류
- **상황**: K8s 노드에서 GitLab Registry 이미지 Pull 시 실패
- **에러**: `http: server gave HTTP response to HTTPS client`
- **원인**: containerd가 기본적으로 HTTPS로 접근하는데 GitLab Registry는 HTTP 사용
- **해결**: 모든 K8s 노드에 containerd 설정 추가
```bash
sudo tee /etc/containerd/certs.d/172.100.100.8:5050/hosts.toml <<EOF
server = "http://172.100.100.8:5050"
[host."http://172.100.100.8:5050"]
  capabilities = ["pull", "resolve", "push"]
  skip_verify = true
EOF
sudo systemctl restart containerd
```

### Day 9: Repository not cloned
- **상황**: FastAPI Pod 3개 중 일부만 Git 저장소에 접근 가능, 나머지는 에러
- **에러**: `Repository not cloned`
- **원인**: 각 Pod가 자신만의 로컬 emptyDir 볼륨 사용 → Pod마다 저장소 상태 불일치
- **해결**: NFS 기반 공유 PVC 생성으로 모든 Pod가 동일 저장소 접근
```yaml
volumes:
- name: repos-volume
  persistentVolumeClaim:
    claimName: repos-pvc
```

---

## 슬라이드 14: 트러블슈팅 - Database & Network (1)

### ⭐ Day 6: ExternalName DNS 해석 불가
- **상황**: FastAPI Pod에서 외부 VM의 MySQL Master에 연결 시도
- **에러**: `Name or service not known` (socket.gaierror)
- **원인**: ExternalName Service는 **IP 주소 미지원**, DNS 호스트명만 가능
- **해결**: ClusterIP + Endpoints 방식으로 외부 IP를 K8s Service로 매핑
```yaml
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

### Day 7: Slave_IO_Running: No
- **상황**: K8s MySQL Slave가 Master와 복제 연결을 맺지 못함
- **에러**: `Slave_IO_Running: No`, `Slave_SQL_Running: No`
- **원인**: Master 접속 실패 또는 여러 Slave Pod가 동일한 server-id 사용
- **해결**: mysql-master 서비스/Endpoints 확인, initContainer로 server-id 자동 할당

---

## 슬라이드 15: 트러블슈팅 - Database & Network(OAuth) (2)

### Day 9: MySQL 연결 불가
- **상황**: 갑자기 K8s Pod에서 외부 MySQL Master 연결 불가
- **에러**: `Can't connect to MySQL server on 'mysql-master'`
- **원인**: Docker와 iptables 규칙 충돌 (UFW 방화벽이 Docker 규칙 덮어씀)
- **해결**: 
```bash
sudo ufw disable
sudo systemctl restart docker
```

### Day 9: Replication 실패
- **상황**: MySQL Slave Pod가 Master에 복제 연결을 시도하지만 인증 실패
- **에러**: `Replica_IO_Running: Connecting`
- **원인**: Master DB에 복제 전용 계정이 없음
- **해결**: Master에서 복제 계정 생성
```sql
CREATE USER 'repl_pista'@'%' IDENTIFIED BY '<PASSWORD>';
GRANT REPLICATION SLAVE ON *.* TO 'repl_pista'@'%';
```

### ⭐ Day 10: Duplicate Key 에러
- **상황**: 사용자가 페이지 저장 시 간헐적으로 중복 키 에러 발생
- **에러**: `IntegrityError: Duplicate entry for key 'unique_user_repo_branch'`
- **원인**: 복제 지연 중 Master에서 데이터 생성 → Slave에서 읽기 시 없음 → 다시 생성 시도
- **해결**: Read/Write 모두 Master 사용 (임시 조치), 향후 InnoDB Cluster로 전환

### Day 9: OAuth 콜백 후 404
- **상황**: GitHub 로그인 후 콜백 URL에서 404 에러
- **에러**: `/auth/callback` 에서 404 Not Found
- **원인**: Ingress가 `/auth/*`를 모두 백엔드로 라우팅 (프론트엔드 콜백 페이지 접근 불가)
- **해결**: `/auth/github/*`만 백엔드, 나머지는 프론트엔드로 라우팅

---

## 슬라이드 16: 마무리

### 진행 현황
- **v0.1 Core Platform**: 85% 완료
- **Infrastructure**: 100% 완료

### 다음 단계
1. 마크다운 렌더링 구현
2. 코드 블록 구문 강조
3. 커밋 그래프 시각화

### 배운 점
- Kubernetes 클러스터 운영 경험
- MySQL Master-Slave 복제 구성
- GitHub/GitLab 하이브리드 CI/CD 파이프라인

---

## 슬라이드 16: Q&A

### 감사합니다

**프로젝트 저장소**
- GitHub: [repository-url]
- Demo: http://gition.local

**연락처**
- Email: [email]
