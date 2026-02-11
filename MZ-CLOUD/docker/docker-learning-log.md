# Docker 학습 가이드

## 📚 목차

- [Day 1 - Docker 기초](#day-1---docker-기초)
- [Day 2 - 이미지 & MySQL](#day-2---이미지--mysql)
- [Day 4 - Private Registry](#day-4---private-registry)
- [Day 5 - 네트워크](#day-5---네트워크)
- [Day 6 - Docker Compose](#day-6---docker-compose)

---

## Day 1 - Docker 기초

> Ubuntu 컨테이너, Nginx 웹서버, Volume Mount

```mermaid
flowchart LR
    Host[🖥️ Host] -->|docker run| Container[🐳 Container]
    Host -->|-v mount| Container
```

📖 [상세 문서](./day1-1126/README.md)

---

## Day 2 - 이미지 & MySQL

> Nginx 이미지, Docker Commit, MySQL 구축

```mermaid
flowchart LR
    Container[🐳 Container] -->|commit| Image[📦 Image]
    Image -->|run| NewContainer[🐳 New Container]
```

📖 [상세 문서](./day2-1127/README.md)

---

## Day 4 - Private Registry

> 프라이빗 레지스트리 구축, 이미지 Push/Pull

```mermaid
flowchart LR
    Host1[🖥️ Server] -->|push| Registry[📦 Registry:5000]
    Registry -->|pull| Host2[🖥️ Client]
```

📖 [상세 문서](./day4-1201/README.md)

---

## Day 5 - 네트워크

> 브리지 네트워크, 네트워크 격리, WordPress+MySQL

```mermaid
flowchart TB
    subgraph Bridge1["mynet-bridge-1"]
        C1[Container 1]
        C2[Container 2]
    end
    subgraph Bridge2["mynet-bridge-2"]
        C3[Container 3]
    end
    C1 <-->|✅| C2
    C1 <-.->|❌| C3
```

📖 [상세 문서](./day5-1202/README.md)

---

## Day 6 - Docker Compose

> 다중 컨테이너 관리, WordPress+MySQL+Nginx

```mermaid
flowchart LR
    Compose[docker-compose.yml] --> MySQL[🐬 MySQL]
    Compose --> WordPress[📝 WordPress]
    Compose --> Nginx[🔷 Nginx]
```

📖 [상세 문서](./day6-1203/README.md)
