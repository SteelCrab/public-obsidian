# Kubernetes 학습 가이드

## 📚 목차

- [전체 아키텍처](#전체-아키텍처)
- [Day 1 - 환경 구축](#day-1---환경-구축)
- [Day 2 - 클러스터 구성](#day-2---클러스터-구성)
- [Day 3 - Pod & Service](#day-3---pod--service)
- [Day 4 - Container 패턴](#day-4---container-패턴)
- [Day 5 - Volume](#day-5---volume)
- [Day 6 - Labels & Deployment](#day-6---labels--deployment)
- [Day 7 - MetalLB & MySQL](#day-7---metallb--mysql)

---

## 전체 아키텍처

```mermaid
flowchart TB
    subgraph Cluster["☸️ Kubernetes Cluster"]
        subgraph Master["🎛️ Control Plane"]
            API[API Server]
            ETCD[(etcd)]
            SCHED[Scheduler]
            CM[Controller Manager]
        end
        
        subgraph Workers["👷 Worker Nodes"]
            N1[k8s-n1]
            N2[k8s-n2]
            N3[k8s-n3]
        end
    end
    
    DEV[👨‍💻 Developer] -->|kubectl| API
    API --> ETCD
    API --> SCHED
    API --> CM
    SCHED --> Workers
```

---

## Day 1 - 환경 구축

> Docker, Kubernetes 설치 및 초기 설정

```mermaid
flowchart LR
    VM[🖥️ VMware] --> Ubuntu[Ubuntu 24.04]
    Ubuntu --> Docker[🐳 Docker]
    Docker --> K8s[☸️ Kubernetes]
```

📖 [상세 문서](./day1-1204/README.md)

---

## Day 2 - 클러스터 구성

> Master-Worker 클러스터 구성 및 Calico CNI

```mermaid
flowchart LR
    Master[🎛️ k8s-master] --> N1[k8s-n1]
    Master --> N2[k8s-n2]
    Master --> N3[k8s-n3]
```

| 노드 | IP | 역할 |
|------|-----|------|
| k8s-master | 172.100.100.10 | Control Plane |
| k8s-n1~n3 | 172.100.100.11~13 | Worker |

📖 [상세 문서](./day2-1205/README.md)

---

## Day 3 - Pod & Service

> Pod 생성, Service 노출, Dashboard

```mermaid
flowchart LR
    User[👤] -->|NodePort| SVC[Service]
    SVC --> Pod[🐳 Pod]
```

📖 [상세 문서](./day3-1208/README.md)

---

## Day 4 - Container 패턴

> Deployment, InitContainer, Sidecar

```mermaid
flowchart LR
    subgraph Pod
        Init[Init] --> Main[Main]
        Main <--> Sidecar[Sidecar]
    end
```

📖 [상세 문서](./day4-1209/README.md) | [트러블슈팅](./day4-1209/ISSUE.md)

---

## Day 5 - Volume

> emptyDir, hostPath, PV, PVC

```mermaid
flowchart LR
    Pod[🐳 Pod] --> PVC[PVC]
    PVC --> PV[PV]
    PV --> Storage[(Storage)]
```

📖 [상세 문서](./day5-1210/README.md)

---

## Day 6 - Labels & Deployment

> Label Selector, Service 매칭

```mermaid
flowchart LR
    SVC[Service] -->|selector| Pod1[Pod]
    SVC -->|selector| Pod2[Pod]
    SVC -->|selector| Pod3[Pod]
```

📖 [상세 문서](./day6-1211/README.md)

---

## Day 7 - MetalLB & MySQL

> LoadBalancer, MySQL 전체 구성

```mermaid
flowchart LR
    User[👤] -->|External IP| LB[🔷 MetalLB]
    LB --> SVC[Service]
    SVC --> MySQL[🐬 MySQL]
    MySQL --> PV[(PV)]
```

📖 [상세 문서](./day7-1212/README.md)
