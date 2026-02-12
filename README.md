# public-obsidian

> 원격 저장소를 활용한 Obsidian MD 문서 에디터 관리

## 개요

Zettelkasten (원자적 노트) 스타일로 구성된 문서 볼트입니다.
클라우드 인프라, DevOps, 프로그래밍 주제를 다루며, 각 섹션은 **MOC (Map of Content)** 허브 노트로 연결됩니다.

---

## ☁️ 클라우드 & 인프라

- **[GCP_MOC](./MZ-CLOUD/GCP/GCP_MOC.md)** — Google Cloud Platform
  - gcloud CLI · VPC · Compute Engine · Load Balancer · Cloud Storage · Cloud SQL

- **[AWS_MOC](./MZ-CLOUD/aws/AWS_MOC.md)** — Amazon Web Services
  - EC2 · ASG · Lambda · ECS · EKS · S3 · RDS · VPC · IAM · CloudWatch

- **[OnPremise_MOC](./MZ-CLOUD/on-premise-ict/OnPremise_MOC.md)** — 온프레미스 K8s/Docker 프로젝트
  - 2-Tier / 3-Tier 아키텍처 · Ingress-Nginx · 하이브리드 CI/CD · Trivy 보안 · NFS · DB Replication

- **[PersonalProject_MOC](./MZ-CLOUD/personal-project/PersonalProject_MOC.md)** — VMware K8s 3-Tier HA 시스템
  - InnoDB Cluster · MetalLB · GitLab CI · 12일간 구축 기록

---

## 🐳 컨테이너 & 오케스트레이션

- **[Docker_MOC](./MZ-CLOUD/docker/Docker_MOC.md)** — Docker
  - 이미지 · 컨테이너 · 볼륨 · 네트워크 · Compose · day별 학습 기록

- **[Kubectl_MOC](./MZ-CLOUD/kubernetes/Kubectl_MOC.md)** — Kubernetes
  - 클러스터 · 리소스 관리 · Pod · 스케일링 · Service (ClusterIP / NodePort / LB) · day별 학습 기록

---

## 🔄 CI/CD & 버전 관리

- **[CICD_MOC](./MZ-CLOUD/cicd/CICD_MOC.md)** — CI/CD 파이프라인
  - SSH → SSM → ASG → EKS 배포 진화 · 배포 방식 비교 · GitHub Secrets 종합 · 워크플로우 예시

- **[Git_MOC](./MZ-CLOUD/git/Git_MOC.md)** — Git 명령어 A-Z
  - init · branch · merge · rebase · cherry-pick · stash · hooks · worktree · submodule

- **[GitHub_Actions_MOC](./MZ-CLOUD/github/GitHub_Actions_MOC.md)** — GitHub Actions
  - 트리거 · matrix · secrets · Docker 빌드 · ECR/S3 · SSH/SSM 배포

- **[GitLab_MOC](./MZ-CLOUD/gitlab/GitLab_MOC.md)** — GitLab CI/CD
  - pipeline · runners · container registry

---

## 💻 프로그래밍 & 데이터베이스

- **[Rust_MOC](./MZ-CLOUD/rust/Rust_MOC.md)** — Rust 언어 종합
  - 소유권 · 트레이트 · 제네릭 · async/await · 에러 처리
  - 크레이트: serde · tokio · axum · sqlx · clap · reqwest · tracing
  - 프로젝트: [PipeSQL](./MZ-CLOUD/rust/PipeSQL_MOC.md) · [GlueSQL](./MZ-CLOUD/rust/GlueSQL_MOC.md)

- **[Python_MOC](./MZ-CLOUD/python/Python_MOC.md)** — Python 기초
  - 자료형 · 제어문 · 함수 · FastAPI

- **[Database_MOC](./MZ-CLOUD/database/Database_MOC.md)** — MySQL
  - 설치 · DBMS 개요 · TABLE · JOIN · 백업 · Cron · NoSQL

---

## 🖥️ 시스템

- **[Linux_MOC](./MZ-CLOUD/linux/Linux_MOC.md)** — Linux 관리
  - 사용자 관리 · 권한 · 쉘 스크립트

---

## 📦 프로젝트

- **[GCP_Infra_MOC](GCP_Infra_MOC.md)** — GCP 인프라 자동화
  - 모듈식 스크립트: env → network → compute / sql / lb

- **[GlueSQL_MOC](./MZ-CLOUD/rust/GlueSQL_MOC.md)** — Rust 기반 SQL 엔진
  - AST · Parser · Planner · Executor · 다중 스토리지 백엔드

- **[PipeSQL_MOC](./MZ-CLOUD/rust/PipeSQL_MOC.md)** — TUI DB 클라이언트
  - Rust + ratatui · 스키마 탐색 · SQL 실행

---

## 🔗 링크

- Vault: [MZ-CLOUD](./MZ-CLOUD/)
- [Obsidian](https://obsidian.md/) — 지식 베이스 에디터
