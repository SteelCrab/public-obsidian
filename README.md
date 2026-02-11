# public-obsidian

> 원격 저장소를 활용한 Obsidian MD 문서 에디터 관리

## 개요

Zettelkasten (원자적 노트) 스타일로 구성된 문서 볼트입니다. 클라우드 인프라, DevOps, 프로그래밍 주제를 다루며, 각 섹션은 **MOC (Map of Content)** 허브 노트로 연결됩니다.

---

## 📚 목차

### ☁️ 클라우드 & 인프라

<details>
<summary><b>GCP_MOC</b> — Google Cloud Platform</summary>

- gcloud CLI 설치/설정
- **네트워크**: VPC, Cloud NAT, 방화벽, 네트워크 실습 (AWS 비교)
- **Compute Engine**: VM, 디스크, SSH, 인스턴스 템플릿/MIG, 스냅샷, 비용 최적화
- **Load Balancer**: HTTP/S, TCP/UDP, 내부, CDN
- **Cloud Storage**: 버킷, 객체, IAM, 수명 주기, Pub/Sub 이벤트, 정적 웹 호스팅
- **Cloud SQL**: 인스턴스, 연결 (Auth Proxy, Private/Public IP), HA, 백업, 읽기 복제본

→ [GCP_MOC](./MZ-CLOUD/GCP/GCP_MOC.md)
</details>

<details>
<summary><b>AWS_MOC</b> — Amazon Web Services</summary>

- **설정**: CLI, 프로파일, STS 자격 증명
- **컴퓨팅**: EC2, ASG, Lambda, ECS, EKS
- **스토리지**: S3, EBS
- **데이터베이스**: RDS, DynamoDB
- **네트워크**: VPC, ELB, Route 53
- **보안**: IAM, Secrets Manager, KMS
- **모니터링**: CloudWatch, CloudTrail, Systems Manager
- **배포**: ECR, CodeDeploy, CloudFormation

→ [AWS_MOC](./MZ-CLOUD/aws/AWS_MOC.md)
</details>

<details>
<summary><b>OnPremise_MOC</b> — 온프레미스 K8s/Docker 프로젝트</summary>

- 2-Tier (WordPress + MySQL) / 3-Tier (Nginx + FastAPI + MySQL) 아키텍처
- Ingress-Nginx, NodePort 구성
- 하이브리드 CI/CD: GitHub → GitLab 미러링
- Trivy 컨테이너 보안 스캔
- NFS 볼륨, VM 스냅샷 (virsh)
- MySQL Master-Slave Replication

→ [OnPremise_MOC](./MZ-CLOUD/on-premise-ict/OnPremise_MOC.md)
</details>

<details>
<summary><b>PersonalProject_MOC</b> — VMware K8s 3-Tier HA 시스템</summary>

- On-Premise VMware 환경 Kubernetes 3-Tier 고가용성 시스템
- InnoDB Cluster, MetalLB, GitLab CI
- 12일간의 일별 구축 기록 (Day 1 ~ Day 12)

→ [PersonalProject_MOC](./MZ-CLOUD/personal-project/PersonalProject_MOC.md)
</details>

---

### 🐳 컨테이너 & 오케스트레이션

<details>
<summary><b>Docker_MOC</b> — Docker 명령어, Compose, 네트워크</summary>

- **이미지**: 빌드, pull, push
- **컨테이너**: run, ps, exec, logs
- **스토리지/네트워크**: volume, network
- **오케스트레이션**: Docker Compose
- **이미지 레퍼런스**: FastAPI, Docker PAT
- Day별 학습 기록 (day1 ~ day6)

→ [Docker_MOC](./MZ-CLOUD/docker/Docker_MOC.md)
</details>

<details>
<summary><b>Kubectl_MOC</b> — Kubernetes kubectl 명령어</summary>

- **클러스터**: cluster-info, context 설정
- **리소스**: get, describe, logs, apply, create, delete, edit
- **Pod**: exec, port-forward, cp
- **스케일링**: scale, rollout
- **디버깅**: top, events
- **Service**: ClusterIP, NodePort, LoadBalancer
- Day별 학습 기록 (day1 ~ day7)

→ [Kubectl_MOC](./MZ-CLOUD/kubernetes/Kubectl_MOC.md)
</details>

---

### 🔄 CI/CD & 버전 관리

<details>
<summary><b>CICD_MOC</b> — CI/CD 파이프라인 패턴</summary>

- **4가지 배포 방식**: SSH → SSM → ASG → EKS (진화 과정)
- 배포 방식별 비교 테이블 (대상, 접속 방식, 이미지 저장소, LB, 스케일링)
- GitHub Secrets 종합 레퍼런스
- 워크플로우 예시: FastAPI/Nginx × DockerHub/ECR/SSM
- 실습 프로젝트 브랜치: main, ci/s3, ci/asg, ci/eks-fastapi, ci/eks-rust

→ [CICD_MOC](./MZ-CLOUD/cicd/CICD_MOC.md)
</details>

<details>
<summary><b>Git_MOC</b> — Git 명령어 A-Z</summary>

- **시작**: init, clone, config
- **기본**: status, add, commit, diff, log
- **브랜치**: 생성, 전환, 삭제, 추적
- **원격**: remote, push, pull, fetch, force push
- **병합**: merge, rebase, cherry-pick, 충돌 해결
- **되돌리기**: reset, revert, restore, clean, undo 시나리오
- **고급**: worktree, submodule, bisect, hooks
- **개념 비교**: checkout vs switch, fetch vs pull, merge vs rebase

→ [Git_MOC](./MZ-CLOUD/git/Git_MOC.md)
</details>

<details>
<summary><b>GitHub_Actions_MOC</b> — GitHub Actions 워크플로우</summary>

- **기본 구조**: workflow, triggers, paths, jobs, steps
- **실행 환경**: runners, env, secrets, matrix
- **흐름 제어**: conditions, needs, concurrency
- **Docker 통합**: login, buildx, build & push
- **AWS 통합**: configure, ECR login, S3 sync
- **배포**: SSH/SSM 배포 액션
- 실전 워크플로우 예시 5종

→ [GitHub_Actions_MOC](./MZ-CLOUD/github/GitHub_Actions_MOC.md)
</details>

<details>
<summary><b>GitLab_MOC</b> — GitLab CI/CD</summary>

- GitLab pipeline, runners, container registry

→ [GitLab_MOC](./MZ-CLOUD/gitlab/GitLab_MOC.md)
</details>

---

### 💻 프로그래밍 & 데이터베이스

<details>
<summary><b>Rust_MOC</b> — Rust 언어 종합</summary>

- **기본 문법**: 변수, 데이터 타입, 함수, 제어 흐름
- **소유권 시스템**: ownership, borrowing, lifetimes, slice
- **구조체/열거형**: struct, enum, pattern matching, Option, Result
- **컬렉션**: Vec, String, HashMap
- **반복자/클로저**: closures, iterators, adapters
- **에러 처리**: panic, Result, 에러 전파 (`?`)
- **트레이트/제네릭**: traits, generics, trait bounds
- **동시성**: threads, channels, Mutex, async/await
- **고급**: smart pointers, macros, unsafe, workspace
- **인기 크레이트**: serde, tokio, axum, sqlx, clap, reqwest, tracing, anyhow 등 11종
- **프로젝트**: PipeSQL (TUI DB 클라이언트), GlueSQL (멀티 모델 SQL 엔진)

→ [Rust_MOC](./MZ-CLOUD/rust/Rust_MOC.md)
</details>

<details>
<summary><b>Python_MOC</b> — Python 기초</summary>

- 변수, 데이터타입, 문자열, 제어문, 함수
- FastAPI 프레임워크
- Day별 학습 기록 (day1 ~ day6)

→ [Python_MOC](./MZ-CLOUD/python/Python_MOC.md)
</details>

<details>
<summary><b>Database_MOC</b> — MySQL 종합</summary>

- **설치**: MySQL, MySQL Workbench
- **기본 개념**: DBMS, DATABASE, DATA_TYPE
- **테이블 & 쿼리**: TABLE, JOIN
- **관리**: 쉘 명령어, 백업/복구, Cron 스케줄링
- **NoSQL**: NoSQL 개요

→ [Database_MOC](./MZ-CLOUD/database/Database_MOC.md)
</details>

---

### 🖥️ 시스템

<details>
<summary><b>Linux_MOC</b> — Linux 시스템 관리</summary>

- 사용자 관리 스크립트
- 권한 관리, 쉘 명령어

→ [Linux_MOC](./MZ-CLOUD/linux/Linux_MOC.md)
</details>

---

### 📦 프로젝트 관련

<details>
<summary><b>GCP_Scripts_MOC</b> — GCP 인프라 자동화 스크립트</summary>

- VPC/서브넷, VM, Load Balancer, Cloud SQL 자동 구축/정리
- 모듈식 구조: env → network → compute/sql/lb

→ [GCP_Scripts_MOC](./MZ-CLOUD/GCP/GCP_Scripts_MOC.md)
</details>

<details>
<summary><b>GlueSQL_MOC</b> — Rust 기반 SQL 엔진 내부 구조</summary>

- AST, Parser, Planner, Executor, Store 인터페이스
- 다양한 스토리지 백엔드 (메모리, CSV, JSON, Redis 등)

→ [GlueSQL_MOC](./MZ-CLOUD/rust/GlueSQL_MOC.md)
</details>

<details>
<summary><b>PipeSQL_MOC</b> — TUI 데이터베이스 클라이언트</summary>

- Rust + ratatui 기반 터미널 UI 데이터베이스 클라이언트
- 스키마 탐색, SQL 실행, 이벤트 시스템

→ [PipeSQL_MOC](./MZ-CLOUD/rust/PipeSQL_MOC.md)
</details>

---

## 🔗 링크

- Vault: [MZ-CLOUD](./MZ-CLOUD/)
- [Obsidian](https://obsidian.md/) — 지식 베이스 에디터
