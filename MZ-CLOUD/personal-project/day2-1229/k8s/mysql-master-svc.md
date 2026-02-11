# MySQL Master 서비스

> MySQL Master(172.100.100.11)를 K8s 내부에서 접근하기 위한 **ClusterIP + Endpoints** 서비스입니다.

## 구성 요소

| 리소스 | 이름 | 네임스페이스 | 설명 |
|--------|------|-------------|------|
| Service | `mysql-master` | gition | ClusterIP 서비스 (외부 Endpoints 연결) |
| Endpoints | `mysql-master` | gition | 외부 MySQL Master IP (172.100.100.11) |

## 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                           │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ api-svc (FastAPI Pods)                                  │    │
│  │   env: MYSQL_WRITE_HOST=mysql-master                    │    │
│  └───────────────────────────┬─────────────────────────────┘    │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────┐               │
│  │ Service: mysql-master                        │               │
│  │   type: ClusterIP                            │               │
│  │   port: 3306                                 │               │
│  └────────────────────────┬─────────────────────┘               │
│                           │                                     │
│  ┌─────────────────────────────────────────────┐                │
│  │ Endpoints: mysql-master                     │                │
│  │   - ip: 172.100.100.11                      │                │
│  │   - port: 3306                              │                │
│  └─────────────────────────────────────────────┘                │
│                           │                                     │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ External MySQL Master (VM: 172.100.100.11)                      │
│   - Docker Compose로 운영                                       │
│   - gition database                                              │
│   - GTID 복제 활성화                                             │
└─────────────────────────────────────────────────────────────────┘
```

## 왜 Endpoints를 사용하나?

ExternalName 서비스는 IP를 직접 사용할 수 없고 DNS 이름만 지원합니다.
외부 IP를 사용하려면 **Service + Endpoints** 조합이 필요합니다.

| 방식 | Service Type | 사용 가능 |
|------|-------------|----------|
| ExternalName | ExternalName | DNS 이름만 ❌ |
| **Service + Endpoints** | ClusterIP | IP 주소 ✅ |

## 배포 명령어

```bash
kubectl apply -f mysql-master-svc.yaml
```

## 연결 확인

```bash
# 서비스 확인
kubectl get svc mysql-master -n gition

# Endpoints 확인
kubectl get endpoints mysql-master -n gition

# DNS 확인
kubectl run test --image=busybox -n gition --rm -it --restart=Never -- nslookup mysql-master

# 결과 예시:
# Name:      mysql-master
# Address:   10.x.x.x (ClusterIP)
```

## FastAPI에서 사용

```python
# database.py
MYSQL_WRITE_HOST = os.getenv("MYSQL_WRITE_HOST", "mysql-master")
# → K8s DNS로 mysql-master.gition.svc.cluster.local 연결
# → Endpoints를 통해 172.100.100.11로 트래픽 전달
```
