# NFS Client Provisioner

> Kubernetes에서 PVC 요청 시 NFS 볼륨을 자동으로 생성(동적 프로비저닝)하는 구성 요소

## 개념도
```
             Kubernetes Cluster
 ┌──────────────────────────────────────────────────┐
 │  PVC 생성 요청                                   │
 │       │                                          │
 │       ▼                                          │
 │  ┌────────────────────────────────────┐          │
 │  │ NFS Provisioner                    │          │
 │  │ (kube-system)                      │          │
 │  │ -> StorageClass: nfs-client        │          │
 │  └────────────────────────────────────┘          │
 │       │                                          │
 │       │ 폴더 자동 생성                           │
 │       │                                          │
 └───────┼──────────────────────────────────────────┘
         │
         ▼ NFS Mount
 ┌──────────────────────────────────────────────────┐
 │ NFS Server (172.100.100.10)                      │
 │ /mnt/DATA/{namespace}-{pvcName}-{pvName}         │
 └──────────────────────────────────────────────────┘
```

## 구성 요소

| 리소스 | 이름 | 네임스페이스 |
|--------|------|-------------|
| ServiceAccount | nfs-client-provisioner | kube-system |
| ClusterRole | nfs-client-provisioner-runner | - |
| ClusterRoleBinding | run-nfs-client-provisioner | - |
| Role | leader-locking-nfs-client-provisioner | kube-system |
| RoleBinding | leader-locking-nfs-client-provisioner | kube-system |
| Deployment | nfs-client-provisioner | kube-system |
| StorageClass | nfs-client | - |

## 환경 설정 (수정 필요)

| 변수 | 현재 값 | 설명 |
|------|---------|------|
| `NFS_SERVER` | 172.100.100.10 | NFS 서버 IP |
| `NFS_PATH` | /mnt/DATA | NFS 공유 경로 |

## StorageClass 설정

| 항목 | 값 | 설명 |
|------|-----|------|
| **name** | nfs-client | PVC에서 참조 |
| **provisioner** | k8s-sigs.io/nfs-subdir-external-provisioner | Provisioner 식별자 |
| **reclaimPolicy** | Delete | PVC 삭제 시 PV도 삭제 |
| **archiveOnDelete** | false | 삭제 시 폴더 보존 안 함 |
| **is-default-class** | true | 기본 StorageClass로 지정 |

## 서버 준비 사항
### NFS 서버 설정 (172.100.100.10)

```bash
# NFS 서버 설치
sudo apt install nfs-kernel-server

# 공유 디렉토리 생성
sudo mkdir -p /mnt/DATA
sudo chown nobody:nogroup /mnt/DATA

# /etc/exports 설정
echo "/mnt/DATA 172.100.100.0/24(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports

# NFS 재시작
sudo exportfs -ra
sudo systemctl restart nfs-kernel-server
```

## 배포 명령어
```bash
kubectl apply -f nfs-provisioner.yaml

# 확인
kubectl get pods -n kube-system -l app=nfs-client-provisioner
kubectl get storageclass
```

## PVC 테스트 예시

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nfs-client  # StorageClass 지정
  resources:
    requests:
      storage: 1Gi
```

## 참고
- Helm으로 설치 시: `helm install nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner`
