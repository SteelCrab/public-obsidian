# Day 8 - GitLab 서버 이전 (Linux → Windows Host) (01/04)

> 기존 Linux Host의 GitLab 환경을 Windows Host로 이전하여 구조 단순화

## 📋 목차

1. [개요](#-개요)
2. [기존 환경 정리](#-기존-환경-정리)
3. [Windows Host 환경 구성](#-windows-host-환경-구성)
4. [GitLab 서버 구축/이전](#-gitlab-서버-구축이전)
5. [K8s 연동 재설정](#-k8s-연동-재설정)
6. [검증](#-검증)

---

## 📌 개요

### 이전 전/후 비교

| 구분 | 이전 (Before) | 이후 (After) |
|------|--------------|--------------| 
| **물리 Host** | Linux (192.168.45.87) | Windows (192.168.45.139) |
| **가상화** | virsh/KVM | VMware |
| **GitLab VM IP** | 192.168.5.8 | **172.100.100.8** (K8s와 동일 네트워크) |
| **Registry** | 192.168.5.8:5050 | **172.100.100.8:5050** |

### 이전 네트워크 구조 (Before)

```
┌──────────────────────────────────────────────────────────────────────────┐
│             Windows Host (192.168.45.139)                                │
│ ┌──────────────────────────────────────────────────────────────────────┐ │
│ │        VMware NAT (172.100.100.0/24)                                 │ │
│ │ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                  │ │
│ │ │k8s-m     │ │k8s-n1    │ │k8s-n2    │ │k8s-n3    │                  │ │
│ │ │.12       │ │.13       │ │.14       │ │.15       │                  │ │
│ │ └──────────┘ └──────────┘ └──────────┘ └──────────┘                  │ │
│ └──────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────┘
                              │
                              │192.168.45.x (LAN) + 2단계 포트포워딩
                              │
┌──────────────────────────────────────────────────────────────────────────┐
│             Linux Host (192.168.45.87)                                   │
│ ┌──────────────────────────────────────────────────────────────────────┐ │
│ │        virsh/KVM NAT (192.168.5.0/24)                                │ │
│ │ ┌────────────────────────────────────────────────────────────────┐   │ │
│ │ │GitLab + Runner + Registry (192.168.5.8:5050)                   │   │ │
│ │ └────────────────────────────────────────────────────────────────┘   │ │
│ └──────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────┘
```

### 이후 네트워크 구조 (After)

```
┌──────────────────────────────────────────────────────────────────────────┐
│             Windows Host (192.168.45.139)                                │
│ ┌──────────────────────────────────────────────────────────────────────┐ │
│ │        VMware NAT (172.100.100.0/24)                                 │ │
│ │                                                                      │ │
│ │ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                  │ │
│ │ │k8s-m     │ │k8s-n1    │ │k8s-n2    │ │k8s-n3    │                  │ │
│ │ │.12       │ │.13       │ │.14       │ │.15       │                  │ │
│ │ └──────────┘ └──────────┘ └──────────┘ └──────────┘                  │ │
│ │        │                                                             │ │
│ │        └───────── 직접 통신 (같은 네트워크) ──────────┐              │ │
│ │                                                      │              │ │
│ │ ┌────────────────────────────────────────────────────────────────┐  │ │
│ │ │GitLab + Runner + Registry (172.100.100.8:5050)                 │  │ │
│ │ └────────────────────────────────────────────────────────────────┘  │ │
│ └──────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────┘
```

### 이전 장점

| 장점 | 설명 |
|------|------|
| **네트워크 간소화** | 2단계 포트포워딩 → **직접 통신** |
| **지연시간 감소** | 같은 네트워크 내 통신 |
| **관리 편의** | 단일 Host, 단일 네트워크에서 모든 VM 관리 |

---

## 🧹 기존 환경 정리

> Linux Host (192.168.45.87)에서 실행

### 1. 포트포워딩 규칙 제거

```bash
# 현재 규칙 확인
# 들어오는 패킷의 목적지 변경 규칙 확인 (DNAT)
sudo iptables -t nat -L PREROUTING -n -v --line-numbers
# 나가는 패킷의 출발지 변경 규칙 확인 (MASQUERADE)
sudo iptables -t nat -L POSTROUTING -n -v --line-numbers
```

#### 삭제할 규칙

| 체인 | 번호 | 포트 | 대상 | 삭제 |
|------|------|------|------|------|
| PREROUTING | 1 | 5050 | `192.168.5.8:5050` (Registry) | ✅ |
| PREROUTING | **2** | - | **DOCKER** (Docker 자체) | ❌ 유지 |
| PREROUTING | 3 | 80 | `192.168.5.8:80` (GitLab Web) | ✅ |
| PREROUTING | 4 | 80 | `192.168.5.8:80` (중복) | ✅ |
| POSTROUTING | 4 | 5050 | `192.168.5.8` MASQUERADE | ✅ |

```bash
# ⚠️ 번호가 큰 것부터 삭제 (번호 바뀜 방지)
# ⚠️ DOCKER 규칙(2번)은 삭제 금지!

# PREROUTING 규칙 삭제 (GitLab 관련 1, 3, 4번)
sudo iptables -t nat -D PREROUTING 4   # 80 포트 (중복)
sudo iptables -t nat -D PREROUTING 3   # 80 포트
sudo iptables -t nat -D PREROUTING 1   # 5050 포트

# POSTROUTING 규칙 삭제 (GitLab 관련 4번)
sudo iptables -t nat -D POSTROUTING 4  # 192.168.5.8:5050 MASQUERADE

# 확인
sudo iptables -t nat -L PREROUTING -n -v --line-numbers
sudo iptables -t nat -L POSTROUTING -n -v --line-numbers
```

### 2. Bastion 포트포워딩 제거 (172.100.100.9)

```bash
# Bastion VM에서 실행

# 규칙 확인 
sudo iptables -t nat -L PREROUTING -n -v --line-numbers
sudo iptables -t nat -L POSTROUTING -n -v --line-numbers
```

#### 삭제할 규칙 (Bastion)

| 체인 | 번호 | 포트 | 대상 | 삭제 |
|------|------|------|------|------|
| PREROUTING | 1 | 5050 | `192.168.45.87:5050` | ✅ |
| PREROUTING | 2 | - | `192.168.5.8` (자체) | ❌ 확인 필요 |
| PREROUTING | 3 | 80 | `192.168.45.87:80` | ✅ |
| PREROUTING | 4 | 80 | `192.168.45.87:80` (중복) | ✅ |
| POSTROUTING | 1 | 5050 | `192.168.45.87` MASQUERADE | ✅ |

```bash
# 규칙 삭제 (번호가 큰 것부터)
sudo iptables -t nat -D PREROUTING 4   # 80 포트 (중복)
sudo iptables -t nat -D PREROUTING 3   # 80 포트
sudo iptables -t nat -D PREROUTING 1   # 5050 포트

sudo iptables -t nat -D POSTROUTING 1  # 5050 MASQUERADE
```

### 3. (선택) GitLab 데이터 백업

> 기존 데이터를 이전하려는 경우

```bash
# 기존 GitLab VM (Linux Host 내 192.168.5.8)에서
sudo gitlab-backup create
ls -la /var/opt/gitlab/backups/

# 설정 파일 백업
sudo cp /etc/gitlab/gitlab.rb ~/gitlab.rb.bak
sudo cp /etc/gitlab/gitlab-secrets.json ~/gitlab-secrets.json.bak
sudo cp /etc/gitlab-runner/config.toml ~/config.toml.bak
```

### 4. 기존 GitLab VM 종료

```bash
# Linux Host에서
virsh shutdown gitlab-vm
virsh list --all
```

---

## 💻 Windows Host 환경 구성

### 1. VMware 네트워크 설정

GitLab VM을 K8s와 **같은 네트워크(172.100.100.0/24)**에 배치

| 설정 | 값 |
|------|-----|
| Network | VMnet8 (NAT) |
| Subnet | 172.100.100.0/24 |
| GitLab IP | **172.100.100.8** |

### 2. GitLab VM 생성

| 항목 | 권장 사양 |
|------|----------|
| OS | Ubuntu 22.04 LTS |
| vCPU | 4+ |
| RAM | 8GB+ (16GB 권장) |
| Disk | 100GB+ |
| Network | NAT (172.100.100.0/24) |
| **IP** | **172.100.100.8** (고정) |

### 3. VM 네트워크 고정 IP 설정

```bash
sudo vim /etc/netplan/00-installer-config.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens33:  # ip a 로 인터페이스 확인
      dhcp4: no
      addresses:
        - 172.100.100.8/24
      routes:
        - to: default
          via: 172.100.100.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

```bash
sudo netplan apply
ip addr show
```

---

## 🦊 GitLab 서버 구축/이전
> 상세 설치 과정은 [Day 3 - GitLab CE 서버 구축](../day3-1230/README.md#-gitlab-ce-서버-구축) 참조

### 설치 요약

| 단계 | 명령어/설정 | 참조 |
|------|------------|------|
| Swap 생성 | `fallocate`, `mkswap` | [Day3 - Swap](../day3-1230/README.md#1-swap-생성-ram-부족시) |
| GitLab CE 설치 | `apt install gitlab-ce` | [Day3 - 설치](../day3-1230/README.md#2-gitlab-ce-설치) |
| gitlab.rb 설정 | `external_url`, `registry_external_url` | [Day3 - 설정](../day3-1230/README.md#3-gitlab-설정) |
| 방화벽 | `ufw allow 80,443,5050` | [Day3 - 방화벽](../day3-1230/README.md#4-방화벽-설정) |
| Docker 설치 | docker-ce | [Day3 - Docker](../day3-1230/README.md#1-docker-설치) |
| Runner 설치/등록 | `gitlab-runner register` | [Day3 - Runner](../day3-1230/README.md#-gitlab-runner-구축) |
| insecure-registries | `/etc/docker/daemon.json` | [Day3 - Registry](../day3-1230/README.md#5-insecure-registries-설정) |

### 특이 설정 확인

```bash
# /etc/gitlab/gitlab.rb
external_url 'http://172.100.100.8'
registry_external_url 'http://172.100.100.8:5050'
gitlab_rails['registry_enabled'] = true
```

```bash
sudo gitlab-ctl reconfigure
sudo gitlab-ctl status
```

### (선택) 백업 복원

```bash
sudo cp /path/to/backup/*_gitlab_backup.tar /var/opt/gitlab/backups/
sudo cp /path/to/backup/gitlab-secrets.json.bak /etc/gitlab/gitlab-secrets.json

sudo gitlab-ctl stop puma && sudo gitlab-ctl stop sidekiq
sudo gitlab-backup restore BACKUP=<타임스탬프>
sudo gitlab-ctl reconfigure && sudo gitlab-ctl restart
```

---

## 📚 K8s 연동 재설정
### K8s ↔ GitLab 접근 방법

> 기존: K8s → Bastion (172.100.100.9:5050) → Linux Host → GitLab
> **변경: K8s → GitLab (172.100.100.8) 직접 통신!**

**포트포워딩 불필요!** 같은 네트워크이므로 직접 접근 가능
```bash
# K8s 노드에서 테스트
curl http://172.100.100.8:5050/v2/
ping 172.100.100.8
```

### K8s insecure-registries 업데이트

```bash
# 각 K8s 노드에서
sudo vim /etc/docker/daemon.json
```

```json
{
  "insecure-registries": [
    "172.100.100.8:5050"
  ]
}
```

```bash
sudo systemctl restart docker
```

### 일괄 적용 스크립트

```bash
for node in k8s-m k8s-n1 k8s-n2 k8s-n3; do
  ssh $node "sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  \"insecure-registries\": [
    \"172.100.100.8:5050\"
  ]
}
EOF
sudo systemctl restart docker"
done
```

### K8s Secret 재생성
> 상세 과정은 [Day 3 - Registry Secret 설정](../day3-1230/README.md#-registry-secret-설정) 참조

```bash
# 기존 Secret 삭제 (만약 잘못된 주소면)
kubectl delete secret gitlab-external gitlab-registry -n gition

# 새 Secret 생성
kubectl create secret docker-registry gitlab-registry \
  --docker-server=172.100.100.8:5050 \
  --docker-username=root \
  --docker-password=<ACCESS_TOKEN> \
  -n gition
```

### Deployment 이미지 경로 변경
```yaml
spec:
  template:
    spec:
      imagePullSecrets:
      - name: gitlab-registry
      containers:
      - name: api
        image: 172.100.100.8:5050/root/gition/api:latest
```

---

## ✅ 검증
### 1. GitLab 서비스 확인

```bash
# GitLab VM (172.100.100.8)에서
sudo gitlab-ctl status
curl http://localhost/api/v4/version
```

### 2. Registry 접속 테스트
```bash
# GitLab VM에서
docker login 172.100.100.8:5050

# K8s 노드에서 (직접 통신!)
curl http://172.100.100.8:5050/v2/
# 토큰 로그인
docker login 172.100.100.8:5050
# id : root
# password : <ACCESS_TOKEN>
docker pull 172.100.100.8:5050/root/gition/api:latest
```

### 3. CI/CD 파이프라인 테스트
1. GitLab UI → CI/CD → Pipelines → **Run pipeline**
2. 빌드 및 Registry push 확인

### 4. K8s 배포 테스트
```bash
kubectl rollout restart deployment/<name> -n gition
kubectl get pods -n gition -w
```

---

## ⚠️ 트러블슈팅
| 오류 | 원인 | 해결 |
|------|------|------|
| Connection refused | 방화벽 또는 IP 오류 | `ufw status`, IP 확인 |
| ImagePullBackOff | insecure-registries 미설정 | daemon.json 확인, Docker 재시작 |
| unauthorized | Token 오류 | Access Token 재발급, Secret 재생성 |
| manifest unknown | 이미지가 Registry에 없음 | CI/CD 파이프라인 실행 또는 수동 빌드/Push |

### Runner에서 GitLab 접근 불가

**오류 메시지:**
```
fatal: unable to access 'http://172.100.100.8/root/gition.git/': 
Failed to connect to 172.100.100.8 port 80: Could not connect to server
```

**원인:** Runner가 Docker 컨테이너 내에서 실행되어 호스트 네트워크에 접근 불가

**해결:** `/etc/gitlab-runner/config.toml` 수정

```toml
[[runners]]
  name = "docker-runner"
  url = "http://172.100.100.8"
  clone_url = "http://172.100.100.8"   # ← 추가!
  ...
  
  [runners.docker]
    ...
    network_mode = "host"              # ← 추가!
```

```bash
# 적용
sudo gitlab-runner restart
sudo gitlab-runner verify
```

### K8s에서 HTTP Registry 접근 불가

**오류 메시지:**
```
Failed to pull image "172.100.100.8:5050/root/gition/backend:latest": 
http: server gave HTTP response to HTTPS client
```

**원인:** K8s의 containerd가 HTTPS로 접근하려는데 Registry는 HTTP만 지원
**해결:** 모든 K8s 노드에서 containerd 설정

```bash
# 각 노드에서 실행 (k8s-m, k8s-n1, k8s-n2, k8s-n3)

# 1. containerd config 디렉토리 생성
sudo mkdir -p /etc/containerd/certs.d/172.100.100.8:5050

# 2. 설정 파일 생성
sudo tee /etc/containerd/certs.d/172.100.100.8:5050/hosts.toml > /dev/null <<EOF
server = "http://172.100.100.8:5050"

[host."http://172.100.100.8:5050"]
  capabilities = ["pull", "resolve", "push"]
  skip_verify = true
EOF

# 3. containerd 재시작
sudo systemctl restart containerd
```

**일괄 적용 스크립트:**

```bash
for node in k8s-m k8s-n1 k8s-n2 k8s-n3; do
  echo "=== $node ==="
  ssh $node "sudo mkdir -p /etc/containerd/certs.d/172.100.100.8:5050 && \
  sudo tee /etc/containerd/certs.d/172.100.100.8:5050/hosts.toml > /dev/null <<EOF
server = \"http://172.100.100.8:5050\"

[host.\"http://172.100.100.8:5050\"]
  capabilities = [\"pull\", \"resolve\", \"push\"]
  skip_verify = true
EOF
  sudo systemctl restart containerd"
done
```

**적용 후 Pod 재시작:**

```bash
kubectl delete pod -n gition -l app=api
kubectl get pods -n gition -w
```

### ExternalName 서비스에서 IP 주소 DNS 해석 불가

**오류 메시지:**
```python
socket.gaierror: [Errno -2] Name or service not known
```

**원인:** ExternalName 서비스는 **DNS 호스트명만 지원**, IP 주소 불가

```yaml
# ❌ 잘못된 설정 (IP 주소)
spec:
  type: ExternalName
  externalName: 172.100.100.11  # DNS 해석 안 됨
```

**해결:** ClusterIP 서비스 + Manual Endpoints 사용

```yaml
# ✅ 올바른 설정
apiVersion: v1
kind: Service
metadata:
  name: mysql-master
  namespace: gition
spec:
  ports:
  - port: 3306
    targetPort: 3306
---
apiVersion: v1
kind: Endpoints
metadata:
  name: mysql-master
  namespace: gition
subsets:
  - addresses:
      - ip: 172.100.100.11    # 외부 IP
    ports:
      - port: 3306
```

```bash
kubectl apply -f mysql-master-svc.yaml
kubectl get svc,endpoints mysql-master -n gition
```

---

## 📚 참고

- [Day 3 - GitLab CE 서버 구축](../day3-1230/README.md#-gitlab-ce-서버-구축)
- [Day 3 - GitLab Runner 구축](../day3-1230/README.md#-gitlab-runner-구축)
- [Day 3 - Registry Secret 설정](../day3-1230/README.md#-registry-secret-설정)
- [Day 3 - 포트포워딩 설정](../day3-1230/README.md#-포트포워딩-설정-2단계)
