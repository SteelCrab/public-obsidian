# 📅 Day 5: NFS 기반 Nginx 및 Virsh 스냅샷

Kubernetes 환경에서 NFS 공유 볼륨을 활용한 Nginx 구성 및 libvirt 스냅샷 관리

---

## 📑 목차

1. [🌐 NFS 기반 Nginx](#-nfs-기반-nginx)
2. [📸 Virsh 스냅샷](#-virsh-스냅샷)

---

## 🌐 NFS 기반 Nginx

Kubernetes에서 NFS 공유 볼륨을 사용하여 Nginx 정적 파일을 관리합니다.

### 📂 디렉토리 구조

```
day5-1219/nfs/nginx/
├── .env              # 환경 변수 설정
├── Dockerfile        # Nginx 이미지 빌드
├── nginx.yaml        # Kubernetes 매니페스트
└── README.md         # 상세 가이드
```

### 🔧 핵심 개념

| 항목 | 설명 |
|------|------|
| **NFS Volume** | 여러 Pod에서 동시에 접근 가능한 공유 스토리지 |
| **PV/PVC** | Persistent Volume 및 Claim 설정 |
| **Pod 공유 볼륨** | 여러 Pod 간 데이터 공유 |

👉 **[상세 가이드 보러가기](./nfs/nginx/README.md)**

---

## 📸 Virsh 스냅샷

libvirt의 virsh를 이용한 VM 스냅샷 관리 명령어 가이드입니다.

### 🔧 주요 명령어

| 카테고리 | 명령어 | 설명 |
|----------|--------|------|
| 🆕 생성 | `snapshot-create-as` | 이름 지정 스냅샷 생성 |
| 📋 조회 | `snapshot-list --tree` | 트리 구조로 목록 확인 |
| 🔄 복구 | `snapshot-revert` | 특정 시점으로 복구 |
| 🗑️ 삭제 | `snapshot-delete` | 스냅샷 삭제 |

### 💡 빠른 예제

```bash
# 스냅샷 생성
virsh snapshot-create-as myvm --name "before-update" --description "업데이트 전 백업"

# 스냅샷 목록 확인
virsh snapshot-list myvm --tree

# 복구
virsh snapshot-revert myvm --snapshotname "before-update" --running
```

👉 **[상세 가이드 보러가기](./virsh/README.md)**

---

## 🔗 관련 문서

| 문서 | 설명 |
|------|------|
| [NFS Nginx README](./nfs/nginx/README.md) | NFS 볼륨 기반 Nginx 상세 구성 |
| [Virsh 스냅샷 가이드](./virsh/README.md) | libvirt 스냅샷 전체 명령어 |
