# Day 3 - 외부 GitLab Registry 연동 (12/30)

> Day 2에서 구축한 K8s 클러스터를 외부 네트워크의 GitLab Registry 접속

## 📋 목차

1. [개요](#-개요)
2. [GitLab CE 서버 구축](#-gitlab-ce-서버-구축)
3. [GitLab Runner 구축](#-gitlab-runner-구축)
4. [GitHub ↔ GitLab 동기화 스크립트](#-github--gitlab-동기화-스크립트)
5. [포트포워딩 설정 (2단계)](#-포트포워딩-설정-2단계)
6. [K8s 노드 설정](#-k8s-노드-설정)
7. [Registry Secret 설정](#-registry-secret-설정)
8. [Deployment 이미지 변경](#-deployment-이미지-변경)
9. [트러블슈팅](#-트러블슈팅)

---

## 📌 개요

### 네트워크 구조

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
                              │192.168.45.x 네트워크 (같은 LAN)
                              │
┌──────────────────────────────────────────────────────────────────────────┐
│             Linux Host (192.168.45.87)                                   │
│ ┌──────────────────────────────────────────────────────────────────────┐ │
│ │        virsh/KVM NAT (192.168.5.0/24)                                │ │
│ │ ┌────────────────────────────────────────────────────────────────┐   │ │
│ │ │GitLab + Runner + Registry                                      │   │ │
│ │ │192.168.5.8:5050                                                │   │ │
│ │ └────────────────────────────────────────────────────────────────┘   │ │
│ └──────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────┘
```

### 인프라 정보

| 구분 | IP 주소 | 역할 |
|------|---------|------|
| **Bastion** | 172.100.100.9 | VMware 내부 게이트웨이 |
| **Linux Host** | 192.168.45.87 | virsh/KVM 호스트 |
| **GitLab VM** | 192.168.5.8 | GitLab CE + Runner + Registry |
| **K8s Cluster** | 172.100.100.12~15 | Kubernetes (VMware) |

---

## 🦊 GitLab CE 서버 구축

> GitLab VM (192.168.5.8)에서 실행

### 1. Swap 생성 (RAM 부족시)

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
free -h
```

### 2. GitLab CE 설치

```bash
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt install gitlab-ce
```

### 3. GitLab 설정

```bash
sudo vim /etc/gitlab/gitlab.rb
```

```ruby
external_url 'http://192.168.5.8'
registry_external_url 'http://192.168.5.8:5050'
gitlab_rails['registry_enabled'] = true
```

```bash
sudo gitlab-ctl reconfigure
```

### 4. 방화벽 설정

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 5050/tcp
sudo ufw enable
```

### 5. 서비스 확인

```bash
sudo gitlab-ctl status
sudo cat /etc/gitlab/initial_root_password  # 24시간 후 삭제됨
```

### 6. Web UI 접속

```bash
ssh -L 8080:192.168.5.8:80 user@192.168.45.87
```

브라우저: `http://localhost:8080`
- Username: `root`
- Password: 초기 비밀번호

### 7. Import 옵션 활성화

> "No import options available" 오류 시

```bash
sudo gitlab-rails console
```

```ruby
Gitlab::CurrentSettings.update!(import_sources: ['github', 'git', 'gitlab_project'])
exit
```

---

## 🏃 GitLab Runner 구축

> GitLab VM (192.168.5.8)에서 실행

### 1. Docker 설치

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -aG docker $USER
newgrp docker
```

### 2. GitLab Runner 설치

```bash
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt-get install gitlab-runner
```

### 3. Runner 등록

```bash
sudo gitlab-runner register \
  --non-interactive \
  --url "http://192.168.5.8" \
  --token "<RUNNER_TOKEN>" \
  --executor "docker" \
  --docker-image docker:24.0.5 \
  --description "docker-runner"
```

### 4. Docker-in-Docker 설정

```bash
sudo vim /etc/gitlab-runner/config.toml
```

```toml
[[runners]]
  name = "docker-runner"
  url = "http://192.168.5.8"
  executor = "docker"
  [runners.docker]
    tls_verify = false
    image = "docker:24.0.5"
    privileged = true
    volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
```

```bash
sudo gitlab-runner restart
sudo gitlab-runner list
```

### 5. insecure-registries 설정

```bash
sudo tee /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["192.168.5.8:5050"]
}
EOF
sudo systemctl restart docker
```

### 6. 확인

```bash
docker login 192.168.5.8:5050
```

### 7. Runner 이름 변경 (선택)

> Runner 이름은 등록 시 `--description`으로 지정되며, config.toml에서 변경 가능

```bash
# GitLab VM (192.168.5.8)에서
sudo vim /etc/gitlab-runner/config.toml
```

```toml
[[runners]]
  name = "my-custom-runner"  # 이름 변경
  url = "http://192.168.5.8"
  ...
```

```bash
sudo gitlab-runner restart
```

| 설정 위치 | 역할 |
|-----------|------|
| `--description` (등록 시) | 초기 이름 지정 |
| `config.toml`의 `name` | 언제든 변경 가능 |

> [!NOTE]
> 설정 파일 위치: `/etc/gitlab-runner/config.toml` (GitLab VM)

---

## 🔄 GitHub ↔ GitLab 동기화 스크립트

> GitLab CE(무료)는 Pull Mirror를 지원하지 않아 Cron 스크립트로 처리

### 동기화 스크립트 설정

```bash
# GitLab Self-Hosted VM (192.168.5.8)에서 실행

# 1. 디렉토리 생성 및 권한 설정
sudo mkdir -p /opt/mirror
sudo chown -R $USER:$USER /opt/mirror
cd /opt/mirror

# 2. GitLab Cloud에서 Mirror Clone (최초 1회)
git clone --mirror https://oauth2:<GITLAB_CLOUD_TOKEN>@gitlab.com/<username>/<repo>.git repo.git

# 3. 동기화 스크립트 생성
cat > /opt/mirror/sync.sh << 'EOF'
#!/bin/bash
LOG_FILE="/var/log/git-mirror.log"
REPO_DIR="/opt/mirror/repo.git"

echo "$(date '+%Y-%m-%d %H:%M:%S') - 동기화 시작" >> $LOG_FILE
cd $REPO_DIR

git fetch --all --prune >> $LOG_FILE 2>&1
git push --mirror http://oauth2:<SELF_HOSTED_TOKEN>@192.168.5.8/<username>/<repo>.git >> $LOG_FILE 2>&1

echo "$(date '+%Y-%m-%d %H:%M:%S') - 동기화 완료" >> $LOG_FILE
EOF

# 4. 실행 권한 및 로그 파일 설정
chmod +x /opt/mirror/sync.sh
sudo touch /var/log/git-mirror.log
sudo chmod 666 /var/log/git-mirror.log

# 5. 수동 테스트
/opt/mirror/sync.sh
cat /var/log/git-mirror.log

# 6. Cron 등록 (5분마다 자동 실행)
(crontab -l 2>/dev/null; echo "*/5 * * * * /opt/mirror/sync.sh") | crontab -

# 7. Cron 확인
crontab -l
```

> [!WARNING]
> `<GITLAB_CLOUD_TOKEN>`과 `<SELF_HOSTED_TOKEN>`은 실제 토큰으로 교체

---

## 🔀 포트포워딩 설정 (2단계)

> K8s → Bastion → Linux Host → GitLab VM

### 네트워크 경로

```
K8s (172.100.100.x)
    │
    └── Bastion (172.100.100.9)  [1단계 포워딩]
              │
              └── Linux Host (192.168.45.87)  [2단계 포워딩]
                        │
                        └── GitLab VM (192.168.5.8:5050)
```

### 1단계: Bastion (172.100.100.9)

```bash
sudo iptables -t nat -A PREROUTING -p tcp --dport 5050 -j DNAT --to-destination 192.168.45.87:5050
sudo iptables -t nat -A POSTROUTING -p tcp -d 192.168.45.87 --dport 5050 -j MASQUERADE

echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo iptables -t nat -L -n -v
```

### 2단계: Linux Host (192.168.45.87)

```bash
sudo ufw allow 5050/tcp

sudo iptables -t nat -I PREROUTING 1 -p tcp --dport 5050 -j DNAT --to-destination 192.168.5.8:5050
sudo iptables -t nat -A POSTROUTING -p tcp -d 192.168.5.8 --dport 5050 -j MASQUERADE

echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

sudo iptables -t nat -L PREROUTING -n -v --line-numbers
```

### 테스트

```bash
# Bastion에서
curl http://192.168.45.87:5050/v2/

# K8s 노드에서
curl http://172.100.100.9:5050/v2/
```

> [!IMPORTANT]
> K8s에서는 **172.100.100.9:5050** (Bastion IP)로 Registry에 접근

---

## 🏃 K8s 노드 설정

### insecure-registries 추가

> 기존 Registry와 외부 Registry 모두 사용 가능

```bash
sudo vim /etc/docker/daemon.json
```

```json
{
  "insecure-registries": [
    "172.100.100.8:5050",
    "172.100.100.9:5050"
  ]
}
```

| Registry | IP | 용도 |
|----------|-----|------|
| **내부** | 172.100.100.8:5050 | VMware 내부 GitLab |
| **외부** | 172.100.100.9:5050 | Bastion 경유 외부 GitLab |

```bash
sudo systemctl restart docker
docker info | grep -A5 "Insecure Registries"
```

### 일괄 적용 스크립트

```bash
for node in k8s-m k8s-n1 k8s-n2 k8s-n3; do
  ssh $node "sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  \"insecure-registries\": [
    \"172.100.100.8:5050\",
    \"172.100.100.9:5050\"
  ]
}
EOF
sudo systemctl restart docker"
done
```

---

## 🔐 Registry Secret 설정

### GitLab Access Token 발급

| 단계 | 설명 |
|------|------|
| 1 | GitLab Web UI 접속 |
| 2 | User Settings → Access Tokens |
| 3 | `read_registry`, `write_registry` 권한 선택 |
| 4 | Token 발급 및 복사 |

### K8s Secret 생성

> 두 Registry 모두 사용하려면 Secret 2개 생성

```bash
# 내부 Registry Secret (172.100.100.8)
kubectl create secret docker-registry gitlab-internal \
  --docker-server=172.100.100.8:5050 \
  --docker-username=root \
  --docker-password=<ACCESS_TOKEN_INTERNAL> \
  -n gition

# 외부 Registry Secret (172.100.100.9 - Bastion 경유)
kubectl create secret docker-registry gitlab-external \
  --docker-server=172.100.100.9:5050 \
  --docker-username=root \
  --docker-password=<ACCESS_TOKEN_EXTERNAL> \
  -n gition

kubectl get secret -n gition | grep gitlab
```

---

## 🏢 Deployment 이미지 변경

### 이미지 주소 형식

```
<REGISTRY_HOST>:<PORT>/<NAMESPACE>/<PROJECT>/<IMAGE>:<TAG>
```

**예시:**
```yaml
# 내부 Registry
image: 172.100.100.8:5050/root/gition/api:latest

# 외부 Registry (Bastion 경유)
image: 172.100.100.9:5050/root/gition/api:latest
```

### Deployment에서 사용

```yaml
spec:
  template:
    spec:
      imagePullSecrets:
      - name: gitlab-internal
      - name: gitlab-external
      containers:
      - name: api
        image: 172.100.100.9:5050/root/gition/api:latest
```

---

## ⚠️ 트러블슈팅

| 오류 | 원인 | 해결 |
|------|------|------|
| ImagePullBackOff | Registry 접속 실패 | `insecure-registries` 설정 확인 |
| unauthorized | Token 만료/틀림 | Secret 재생성 |
| connection refused | 네트워크 문제 | 방화벽/라우팅 확인 |
| No import options | Import 비활성화 | gitlab-rails console로 활성화 |
| Readiness probe failed | 환경변수 미확장 | bash -c 사용 |

### 접속 테스트

```bash
# K8s 노드에서
curl -v http://172.100.100.9:5050/v2/
docker pull 172.100.100.9:5050/root/gition/api:latest
```

---

## 📚 참고

- [Day 1 - 인프라 구축](../day1-1224/install-3tier/README.md)
- [Day 2 - 애플리케이션 배포](../day2-1229/README.md)
