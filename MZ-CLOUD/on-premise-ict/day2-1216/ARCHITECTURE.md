# 📊 프로젝트 아키텍처 다이어그램

## 1. 🚀 CI/CD 파이프라인

```mermaid
flowchart LR
    subgraph Developer["👨‍💻 Developer"]
        DEV[개발자]
    end
    
    subgraph GitHub["🐙 GitHub"]
        GH[📁 Repo]
        GA[⚡ Actions]
        GHCR[📦 ghcr.io]
    end
    
    subgraph GitLab["🦊 GitLab"]
        GL[📁 Repo]
        GLC[⚙️ CI]
        GLR[📦 Registry]
    end
    
    DEV -->|git push| GH
    GH -->|trigger| GA
    GA -->|build & push| GHCR
    GA -->|mirror| GL
    GL -->|trigger| GLC
    GLC -->|build & push| GLR
```

## 2. ☸️ Kubernetes 3-Tier 아키텍처

```mermaid
flowchart TB
    subgraph Internet["🌐 Internet"]
        USER[👤 사용자]
    end
    
    subgraph K8s["☸️ Kubernetes Cluster"]
        subgraph Frontend["🖥️ Web Tier"]
            NGINX[🔷 Nginx Pod<br/>Port 80]
            NGINX_SVC[🔗 nginx-svc<br/>LoadBalancer]
        end
        
        subgraph Backend["⚡ WAS Tier"]
            FASTAPI[🐍 FastAPI Pod<br/>Port 8000]
            FASTAPI_SVC[🔗 fastapi-service<br/>ClusterIP]
        end
        
        subgraph Database["🗄️ DB Tier"]
            MYSQL[🐬 MySQL Pod<br/>Port 3306]
            MYSQL_SVC[🔗 mysql-service<br/>ClusterIP]
            PVC[(💾 mysql-pvc<br/>1Gi)]
        end
    end
    
    USER -->|HTTP :80| NGINX_SVC
    NGINX_SVC --> NGINX
    NGINX -->|/member proxy| FASTAPI_SVC
    FASTAPI_SVC --> FASTAPI
    FASTAPI -->|pymysql| MYSQL_SVC
    MYSQL_SVC --> MYSQL
    MYSQL --> PVC
```

## 3. 🔄 데이터 흐름

```mermaid
sequenceDiagram
    participant U as 👤 사용자
    participant N as 🔷 Nginx
    participant F as 🐍 FastAPI
    participant M as 🐬 MySQL
    
    U->>N: GET /member
    N->>F: proxy_pass :8000/member
    F->>M: SELECT * FROM users
    M-->>F: Result Set
    F-->>N: JSON Response
    N-->>U: {"message": "success"}
```

## 4. 🐳 Docker 이미지 빌드 흐름

```mermaid
flowchart LR
    subgraph Source["📁 소스 코드"]
        DF1[🐍 fastapi/Dockerfile]
        DF2[🔷 nginx/dockerfile]
        DF3[🐬 mysql/Dockerfile]
    end
    
    subgraph GitHub["🐙 GitHub Actions"]
        GA[🔨 docker build]
    end
    
    subgraph GitLab["🦊 GitLab CI"]
        GC[🔨 docker build]
    end
    
    subgraph Registry["📦 Container Registry"]
        GHCR["ghcr.io/steelcrab/*"]
        GLR["registry.gitlab.com/pyh5523/*"]
    end
    
    DF1 & DF2 & DF3 --> GA --> GHCR
    DF1 & DF2 & DF3 --> GC --> GLR
```

## 5. 🔐 Kubernetes 리소스 관계

```mermaid
flowchart TB
    subgraph Secrets["🔐 Secrets"]
        GRS[🔑 gitlab-registry-secret]
        MS[🔑 mysql-secret]
    end
    
    subgraph Storage["💾 Storage"]
        PV[📀 mysql-pv<br/>1Gi hostPath]
        PVC[📀 mysql-pvc<br/>1Gi]
    end
    
    subgraph Deployments["📦 Deployments"]
        ND[🔷 nginx-deploy]
        FD[🐍 fastapi-deployment]
        MD[🐬 mysql-deployment]
    end
    
    subgraph Services["🔗 Services"]
        NS[nginx-svc<br/>LoadBalancer]
        FS[fastapi-service<br/>ClusterIP]
        MSV[mysql-service<br/>ClusterIP]
    end
    
    GRS -->|imagePullSecrets| ND & FD & MD
    MS -->|env vars| FD & MD
    PV --> PVC --> MD
    ND --> NS
    FD --> FS
    MD --> MSV
```

## 📋 아이콘 범례

| 아이콘 | 의미 |
|--------|------|
| 🐙 | GitHub |
| 🦊 | GitLab |
| 🐍 | Python/FastAPI |
| 🔷 | Nginx |
| 🐬 | MySQL |
| ☸️ | Kubernetes |
| 🐳 | Docker |
| 📦 | Container/Package |
| 🔐 | Secret |
| 💾 | Storage |
