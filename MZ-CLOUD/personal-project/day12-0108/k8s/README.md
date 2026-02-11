# Kubernetes 클러스터 구성

## 선행 조건

### 클러스터 환경

| 항목       | 요구사항                    |
|------------|----------------------------|
| Kubernetes | v1.25+                     |
| 노드 수    | Master 1 + Worker 3 (권장) |
| CNI        | Calico                     |
| Helm       | v3.x                       |

### 네트워크 구성

| 호스트  | IP             | 용도                   |
|---------|----------------|------------------------|
| GitLab  | 172.100.100.8  | Git, CI/CD, Registry   |
| Bastion | 172.100.100.9  | SSH 게이트웨이         |
| NFS     | 172.100.100.10 | 공유 스토리지          |
| MySQL   | 172.100.100.11 | Primary (쓰기)         |
| k8s-m   | 172.100.100.12 | Master (Control Plane) |
| k8s-n1  | 172.100.100.13 | Worker Node 1          |
| k8s-n2  | 172.100.100.14 | Worker Node 2          |
| k8s-n3  | 172.100.100.15 | Worker Node 3          |

### MetalLB IP Pool

| 항목          | 값                             |
|---------------|--------------------------------|
| **Pool Name** | ingress-pool                   |
| **IP 범위**   | 172.100.100.20 - 172.100.100.30 |
| **모드**      | L2 (ARP)                       |

### 사전 설치

```bash
# 1. gition 네임스페이스 생성
kubectl create namespace gition

# 2. Ingress-Nginx Controller (설치 안 된 경우)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/baremetal/deploy.yaml

# 3. MetalLB (설치 안 된 경우)
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

# 4. 각 노드에 MySQL 데이터 디렉토리 생성
for node in k8s-n1 k8s-n2 k8s-n3; do
  ssh $node "sudo mkdir -p /mnt/mysql-data && sudo chmod 777 /mnt/mysql-data"
done

# 5. NFS 서버 설정 (172.100.100.10)
# /mnt/DATA 디렉토리를 172.100.100.0/24 대역에 공유
```

### GitLab Registry Secret (이미지 Pull용)

```bash
kubectl create secret docker-registry gitlab-registry -n gition \
  --docker-server=172.100.100.8:5050 \
  --docker-username=<USERNAME> \
  --docker-password=<PASSWORD>
```

---

## 구현순서

### 1. 인프라 구성

| 순서 | 파일                   | 설명                                 |
|------|------------------------|--------------------------------------|
| 1    | `nfs-provisioner.yaml` | NFS 동적 볼륨 프로비저너             |
| 2    | `metallb-config.yaml`  | LoadBalancer IP Pool (172.100.100.20-30) |

```bash
kubectl apply -f nfs-provisioner.yaml
kubectl apply -f metallb-config.yaml
```

### 2. MySQL InnoDB Cluster

| 순서 | 파일                                   | 설명                       |
|------|----------------------------------------|----------------------------|
| 1    | `mysql-cluster/01-mysql-operator.yaml` | Operator 설치 (Helm 권장)  |
| 2    | `mysql-cluster/02-mysql-secret.yaml`   | Root 비밀번호              |
| 3    | `mysql-cluster/03-local-storage.yaml`  | 노드별 Local PV            |
| 4    | `mysql-cluster/04-innodb-cluster.yaml` | 클러스터 생성 (3 instances)|
| 5    | `mysql-cluster/05-app-user.yaml`       | DB/User/Schema 초기화      |
| 6    | `mysql-cluster/06-mysql-backup.yaml`   | 자동 백업 CronJob          |

```bash
# Operator 설치
helm repo add mysql-operator https://mysql.github.io/mysql-operator/
helm install mysql-operator mysql-operator/mysql-operator \
  --namespace mysql-operator --create-namespace

# 클러스터 구성
cd mysql-cluster
kubectl apply -f 02-mysql-secret.yaml
kubectl apply -f 03-local-storage.yaml
kubectl apply -f 04-innodb-cluster.yaml

# Ready 대기 (3~5분)
kubectl get innodbcluster -n gition -w

# 초기화
kubectl apply -f 05-app-user.yaml
kubectl apply -f 06-mysql-backup.yaml
```

### 3. Secrets

| 파일                   | 설명                         |
|------------------------|------------------------------|
| `github-secret.yaml`   | GitHub OAuth Client ID/Secret|

```bash
# 권장: 직접 생성
kubectl create secret generic github-secret -n gition \
  --from-literal=client-id='<ID>' \
  --from-literal=client-secret='<SECRET>'
```

### 4. Ingress

| 순서 | 파일                     | 설명                           |
|------|--------------------------|--------------------------------|
| 1    | `ingress-nginx-svc.yaml` | Ingress Controller LoadBalancer|
| 2    | `ingress.yaml`           | 라우팅 규칙 (/api, /auth, /)   |

```bash
kubectl apply -f ingress-nginx-svc.yaml
kubectl apply -f ingress.yaml
```

### 5. 애플리케이션

| 파일                                     | 설명                     |
|------------------------------------------|--------------------------|
| `mysql-cluster/07-backend-deployment.yaml` | FastAPI (MySQL Cluster 연동)|
| `frontend.yaml`                          | React + Nginx            |

```bash
kubectl apply -f mysql-cluster/07-backend-deployment.yaml
kubectl apply -f frontend.yaml
```

---

## 파일 목록

| 파일                       | 문서                                               | 설명                         |
|----------------------------|----------------------------------------------------|------------------------------|
| `nfs-provisioner.yaml`     | [nfs-provisioner.md](nfs-provisioner.md)           | NFS StorageClass             |
| `metallb-config.yaml`      | [metallb-config.md](metallb-config.md)             | MetalLB L2 설정              |
| `github-secret.yaml`       | [github-secret.md](github-secret.md)               | GitHub OAuth                 |
| `ingress-nginx-svc.yaml`   | [ingress-nginx-svc.md](ingress-nginx-svc.md)       | Ingress Controller           |
| `ingress.yaml`             | [ingress.md](ingress.md)                           | 라우팅 규칙                  |
| `frontend.yaml`            | [frontend.md](frontend.md)                         | React 프론트엔드             |
| `fastapi-deployment.yaml`  | [fastapi-deployment.md](fastapi-deployment.md)     | FastAPI (Legacy)             |
| `mysql-cluster/`           | [mysql-cluster/README.md](mysql-cluster/README.md) | InnoDB Cluster               |
| `check-cluster.sh`         | -                                                  | 클러스터 상태 확인 스크립트  |

## 상태 확인

```bash
# 전체 상태 확인
./check-cluster.sh

# 개별 확인
kubectl get pods -n gition
kubectl get innodbcluster -n gition
kubectl get ingress -n gition
```

## 접속 테스트

```bash
# hosts 파일 설정 (로컬 PC)
echo "172.100.100.20 gition.local" | sudo tee -a /etc/hosts

# 브라우저 접속
open http://gition.local
```

---

## 트러블 매뉴얼

### Pod 관련

| 증상             | 원인                     | 조치                                                            |
|------------------|--------------------------|-----------------------------------------------------------------|
| ImagePullBackOff | Registry 접근 불가       | `kubectl describe pod <POD>`로 확인, `gitlab-registry` Secret 재생성 |
| CrashLoopBackOff | 앱 에러                  | `kubectl logs <POD> -n gition`으로 원인 확인                    |
| Pending          | 리소스 부족/PVC 바인딩 실패 | `kubectl describe pod`로 Events 확인                          |

```bash
# Pod 상태 확인
kubectl get pods -n gition
kubectl describe pod <POD_NAME> -n gition
kubectl logs <POD_NAME> -n gition
```

### MySQL InnoDB Cluster

| 증상              | 원인          | 조치                                               |
|-------------------|---------------|----------------------------------------------------|
| OFFLINE 상태      | Pod 시작 실패 | `kubectl logs mysql-cluster-0 -n gition -c mysql` 확인 |
| Replication 에러  | GTID 충돌     | MySQL Shell에서 수동 복구                          |
| Router 연결 실패  | 클러스터 미준비| `kubectl get innodbcluster -n gition` 상태 확인    |

```bash
# 클러스터 상태
kubectl get innodbcluster -n gition
kubectl exec -it mysql-cluster-0 -n gition -c mysql -- \
  mysqlsh --uri root@localhost -e "cluster.status()"

# Operator 로그
kubectl logs -n mysql-operator deployment/mysql-operator
```

### Ingress

| 증상        | 원인               | 조치                            |
|-------------|--------------------|---------------------------------|
| 503 에러    | Backend Service 없음 | `kubectl get svc -n gition` 확인 |
| 404 에러    | Ingress 규칙 미적용 | `kubectl get ingress -n gition` 확인 |
| 연결 안 됨  | ExternalIP 미할당  | MetalLB speaker 로그 확인       |

```bash
# Ingress 상태
kubectl get ingress -n gition
kubectl describe ingress gition-ingress -n gition

# Ingress Controller 로그
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

### PVC/Storage

| 증상        | 원인             | 조치                         |
|-------------|------------------|------------------------------|
| Pending     | NFS 연결 실패    | NFS 서버 상태 및 exports 확인|
| Bound 안 됨 | StorageClass 없음| `kubectl get sc` 확인        |

```bash
# PVC 상태
kubectl get pvc -n gition
kubectl describe pvc <PVC_NAME> -n gition

# NFS Provisioner 로그
kubectl logs -n kube-system deployment/nfs-client-provisioner
```

### 전체 초기화 (주의)

```bash
# 모든 리소스 삭제 후 재배포
kubectl delete namespace gition
kubectl create namespace gition
# 위 구축 순서 다시 진행
```
