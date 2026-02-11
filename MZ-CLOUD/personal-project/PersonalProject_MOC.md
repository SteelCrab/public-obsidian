# Personal Project MOC

#프로젝트 #MOC #kubernetes #innodb #cicd

---

On-Premise VMware 환경 기반 Kubernetes 3-Tier 고가용성 시스템 프로젝트 허브 노트.

---

## 인프라 구성

- [Day 1: 3-Tier 환경 구축](./day1-1224/install-3tier/README.md) - VMware, Bastion, NFS, MySQL, K8s

---

## 네트워크 & 서비스

| 호스트 | IP | 용도 |
|--------|-----|------|
| GitLab | 172.100.100.8 | Git, CI/CD, Registry |
| Bastion | 172.100.100.9 | SSH 게이트웨이 |
| NFS | 172.100.100.10 | 공유 스토리지 |
| MySQL | 172.100.100.11 | Primary (쓰기) |
| k8s-m | 172.100.100.12 | Control Plane |
| k8s-n1~n3 | .13~.15 | Worker Node |

---

## K8s 배포 & 운영

- [Day 2: MySQL Master + K8s Slave](./day2-1229/README.md) - Master-Slave Replication
- [Day 3](./day3-1230/README.md) - 배포 진행
- [Day 4](./day4-1231/README.md) - 배포 진행
- [Day 5](./day5-0101/README.md) - 배포 진행
- [Day 6](./day6-0102/README.md) - 배포 진행
- [Day 7: Replication 구성](./day7-0103/README.md) - check-replication, setup-replication

---

## InnoDB Cluster & HA

- [Day 8](./day8-0104/README.md) - InnoDB Cluster 구성
- [Day 9](./day9-0105/README.md) - 구성 진행
- [Day 10](./day10-0106/REAMDE.md) - 구성 진행
- [Day 12: MySQL Cluster](./day12-0108/README.md) - Operator, InnoDB Cluster, Backup, 최종 배포
- [MySQL Cluster K8s 배포 가이드](./day12-0108/k8s/mysql-cluster/README.md)

---

## CI/CD

- [Day 11: GitLab CI/CD](./day11-0107/gitlab/README.md) - Self-hosted Runner

---

## 프로젝트 문서

- [프로젝트 계획서](./프로젝트_계획서/프로젝트_계획서.md)
- [PPT 슬라이드](./프로젝트_계획서/PPT_슬라이드.md)

---

## 빠른 참조

| 상황 | 명령어 |
|------|--------|
| 클러스터 상태 | `kubectl get nodes && kubectl get pods -A` |
| Replication 확인 | `./check-replication.sh` |
| 배포 롤아웃 | `kubectl rollout restart deployment/api -n gition` |
| Registry 이미지 Pull | `172.100.100.8:5050/root/gition/backend:latest` |

---

## 외부 링크

- [MySQL Operator](https://dev.mysql.com/doc/mysql-operator/en/)
- [MetalLB 문서](https://metallb.universe.tf/)
- [Ingress-Nginx](https://kubernetes.github.io/ingress-nginx/)

---

*Zettelkasten 스타일로 구성됨*
