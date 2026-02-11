# On-Premise ICT MOC

#온프레미스 #MOC #kubernetes #docker #cicd

---

Kubernetes 및 Docker 기반 온프레미스 인프라/애플리케이션 구축 프로젝트 허브 노트.

---

## 프로젝트 개요

| 목표 | 설명 |
|------|------|
| 🏛️ 2-Tier/3-Tier 아키텍처 | 멀티 티어 애플리케이션 구축 |
| 🌐 Ingress-Nginx | 클러스터 진입점 구성 |
| 🔄 하이브리드 CI/CD | GitHub + GitLab 파이프라인 |
| 🛡️ 컨테이너 보안 | Trivy 스캔 자동화 |

---

## CI/CD & 파이프라인

- [Day 2-3: CI/CD 파이프라인](./day2-1216_day3-1217/README.md) - GitHub → GitLab 미러링, 3-Tier 배포
- [하이브리드 CI/CD](./day4-1218/github-public+gitlab-private/README.md) - Public + Private 전략

---

## 애플리케이션 아키텍처

- [Day 2: FastAPI 3-Tier](./day2-1216/README.md) - FastAPI + MySQL CI/CD
- [Day 3: Application Architecture](./day3-1217/README.md) - 2-Tier/3-Tier, GitLab Runner
- [2-Tier](./day3-1217/2-tier/README.md) - WordPress + MySQL
- [3-Tier](./day3-1217/3-tier/README.md) - Nginx + FastAPI + MySQL
- [Day 4: Ingress-Nginx](./day4-1218/README.md) - NodePort, Trivy

---

## 인프라 & 스토리지

- [Day 5: NFS + Virsh](./day5-1219/README.md) - NFS 볼륨, VM 스냅샷 관리
- [Day 7: DB Replication](./day7-1223/README.md) - MySQL Master-Slave 복제

---

## 빠른 참조

| 상황 | 명령어 |
|------|--------|
| Ingress 배포 | `envsubst < nginx.yaml \| kubectl apply -f -` |
| 3-Tier 배포 | `kubectl apply -f mysql.yaml && kubectl apply -f fastapi.yaml` |
| DB Replication | `docker compose up -d && kubectl apply -f mysql-slave.yaml` |
| 접속 확인 | `kubectl get svc -n ingress` |

---

## 외부 링크

- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [GitLab CI/CD 문서](https://docs.gitlab.com/ee/ci/)
- [GitHub Actions 문서](https://docs.github.com/en/actions)

---

*Zettelkasten 스타일로 구성됨*
