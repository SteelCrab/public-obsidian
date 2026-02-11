# Day 4 - GitLab CI/CD 및 Containerd 설정 (12/31)

> GitLab Runner CI/CD 파이프라인 구축 및 K8s containerd insecure registry 설정

## 📋 목차

1. [개요](#-개요)
2. [문제 상황](#-문제-상황)
3. [GitLab CI/CD 파이프라인 수정](#-gitlab-cicd-파이프라인-수정)
4. [포트 80 포워딩 추가](#-포트-80-포워딩-추가)
5. [GitLab 외부 URL 변경](#-gitlab-외부-url-변경)
6. [Containerd Insecure Registry 설정](#-containerd-insecure-registry-설정)
7. [K8s Deployment 이미지 경로 수정](#-k8s-deployment-이미지-경로-수정)
8. [트러블슈팅](#-트러블슈팅)

---

## 📌 개요

### 해결한 문제들

| 문제 | 원인 | 해결 |
|------|------|------|
| Job stuck (Pending) | Runner 태그 불일치 | `.gitlab-ci.yml` 태그 수정 |
| Docker API 버전 오류 | client v1.43 < daemon v1.44 | `docker:27` 이미지로 업그레이드 |
| HTTP/HTTPS 오류 | containerd가 HTTPS 사용 | `certs.d` 설정 + `config_path` 수정 |
| 인증 리다이렉트 실패 | `192.168.5.8:80` 접근 불가 | 포트 80 포워딩 + GitLab `external_url` 변경 |
| K8s 이미지 경로 불일치 | CI와 Deployment 이미지명 다름 | Deployment 이미지 경로 수정 |

### 네트워크 경로 (포트 5050 + 80)

```
K8s (172.100.100.x)
    │
    ├── :5050 (Registry)
    │    └── Bastion (172.100.100.9:5050)
    │              └── Linux Host (192.168.45.87:5050)
    │                        └── GitLab VM (192.168.5.8:5050)
    │
    └── :80 (Auth)
          └── Bastion (172.100.100.9:80)
                    └── Linux Host (192.168.45.87:80)
                              └── GitLab VM (192.168.5.8:80)
```

---

## 🛑 문제 상황

### 1. GitLab CI Job Stuck

```
build-backend: Pending
This job is stuck because of one of the following problems:
- No runners for the protected branch
- No runners that match all of the job's tags: mz-win-vm, msi-gition
```

### 2. Docker API 버전 오류

```
Error response from daemon: client version 1.43 is too old. 
Minimum supported API version is 1.44
```

### 3. HTTP/HTTPS 오류

```
Failed to pull image: http: server gave HTTP response to HTTPS client
```

### 4. 인증 리다이렉트 실패

```
failed to fetch anonymous token: dial tcp 192.168.5.8:80: connect: no route to host
```

---

## 🔧 GitLab CI/CD 파이프라인 수정

### Docker 버전 업그레이드

```yaml
# .gitlab-ci.yml
.docker-build:
  tags:
    - msi-gition
  image: docker:27          # 24.0.5 → 27 (API 1.44+ 지원)
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  only:
    refs:
      - main

build-frontend:
  extends: .docker-build
  stage: build
  script:
    - docker build -f frontend/Dockerfile -t $CI_REGISTRY_IMAGE/frontend:$CI_COMMIT_SHA -t $CI_REGISTRY_IMAGE/frontend:latest .
    - docker push $CI_REGISTRY_IMAGE/frontend:$CI_COMMIT_SHA
    - docker push $CI_REGISTRY_IMAGE/frontend:latest

build-backend:
  extends: .docker-build
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE/backend:$CI_COMMIT_SHA -t $CI_REGISTRY_IMAGE/backend:latest ./backend
    - docker push $CI_REGISTRY_IMAGE/backend:$CI_COMMIT_SHA
    - docker push $CI_REGISTRY_IMAGE/backend:latest
```

> [!IMPORTANT]
> Docker 버전 불일치: Runner의 Docker daemon이 25+인 경우, CI 이미지도 25+ 필요

---

## 🔀 포트 80 포워딩 추가

> GitLab 인증 리다이렉트(`/jwt/auth`)를 위해 포트 80의 포워딩 필요

### 1단계: Bastion (172.100.100.9)

```bash
# 포트 80 → Linux Host로 포워딩
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.45.87:80
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

# FORWARD 허용
sudo iptables -I FORWARD 1 -p tcp -d 192.168.45.87 --dport 80 -j ACCEPT

# IP 포워딩 활성화
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
```

### 2단계: Linux Host (192.168.45.87)

```bash
# 포트 80 → GitLab VM으로 포워딩
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.5.8:80
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

# INPUT 허용
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT

# FORWARD 허용
sudo iptables -I FORWARD 1 -p tcp -d 192.168.5.8 --dport 80 -j ACCEPT
sudo iptables -I FORWARD 1 -p tcp -s 192.168.5.8 --sport 80 -j ACCEPT

# IP 포워딩 활성화
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
```

### 테스트

```bash
# Bastion에서
curl -v http://192.168.45.87:80/ 2>&1 | head -10

# K8s 노드에서
curl -v http://172.100.100.9:80/ 2>&1 | head -10
```

---

## 🦊 GitLab 외부 URL 변경

> 인증 리다이렉트 URL을 K8s에서 접근 가능한 IP로 변경

### GitLab 설정 수정 (192.168.5.8)

```bash
sudo vim /etc/gitlab/gitlab.rb
```

```ruby
external_url 'http://172.100.100.9'
registry_external_url 'http://172.100.100.9:5050'
```

```bash
sudo gitlab-ctl reconfigure
```

> [!WARNING]
> `external_url` 변경 시 인증 리다이렉트가 `http://172.100.100.9/jwt/auth`로 바뀜

---

## 📦 Containerd Insecure Registry 설정

> containerd v2.x에서 HTTP 레지스트리 사용을 위한 설정

### 1. hosts.toml 생성 (모든 K8s 노드)

```bash
for node in k8s-m k8s-n1 k8s-n2 k8s-n3; do
  echo "=== $node ==="
  ssh $node 'sudo mkdir -p /etc/containerd/certs.d/172.100.100.9:5050 && \
  sudo tee /etc/containerd/certs.d/172.100.100.9:5050/hosts.toml << EOF
server = "http://172.100.100.9:5050"

[host."http://172.100.100.9:5050"]
  capabilities = ["pull", "resolve"]
  skip_verify = true
EOF'
done
```

### 2. config.toml의 config_path 수정

> **특이**: `config_path`를 단일 경로로 설정

```bash
for node in k8s-m k8s-n1 k8s-n2 k8s-n3; do
  echo "=== $node ==="
  ssh $node "sudo sed -i \"s|config_path = '/etc/containerd/certs.d:/etc/docker/certs.d'|config_path = '/etc/containerd/certs.d'|g\" /etc/containerd/config.toml"
done
```

### 3. containerd 재시작

```bash
for node in k8s-m k8s-n1 k8s-n2 k8s-n3; do
  ssh $node 'sudo systemctl restart containerd'
done
```

### 4. 설정 확인

```bash
# hosts.toml 확인
ssh k8s-n1 'cat /etc/containerd/certs.d/172.100.100.9:5050/hosts.toml'

# config_path 확인
ssh k8s-n1 'grep "config_path" /etc/containerd/config.toml'

# 이미지 Pull 테스트
ssh k8s-n1 'sudo crictl pull 172.100.100.9:5050/root/gition/backend:latest'
```

> [!IMPORTANT]
> containerd v2.x에서는:
> - 플러그인 경로: `plugins."io.containerd.cri.v1.images".registry`
> - `config_path`가 여러 경로(`:` 구분)면 첫 번째만 사용됨

---

## 🏢 K8s Deployment 이미지 경로 수정

> CI에서 빌드한 이미지명과 Deployment 이미지명을 일치시키기

### CI 빌드 이미지명

| 컴포넌트 | CI 이미지명 |
|----------|-------------|
| Frontend | `$CI_REGISTRY_IMAGE/frontend:latest` |
| Backend | `$CI_REGISTRY_IMAGE/backend:latest` |

### Deployment 수정

```yaml
# fastapi-deployment.yaml
spec:
  template:
    spec:
      imagePullSecrets:
      - name: gitlab-registry
      containers:
      - name: api
        image: 172.100.100.9:5050/root/gition/backend:latest  # api → backend

# react-deployment.yaml
spec:
  template:
    spec:
      imagePullSecrets:
      - name: gitlab-registry
      containers:
      - name: react
        image: 172.100.100.9:5050/root/gition/frontend:latest  # react → frontend
```

### Secret 생성/확인

```bash
# Secret 확인
kubectl get secret gitlab-registry -n gition -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d

# Secret 재생성 (필요 시)
kubectl delete secret gitlab-registry -n gition
kubectl create secret docker-registry gitlab-registry \
  --docker-server=172.100.100.9:5050 \
  --docker-username=root \
  --docker-password=<ACCESS_TOKEN> \
  -n gition
```

---

## ⚠️ 트러블슈팅

### 오류별 해결 방법

| 오류 | 원인 | 해결 |
|------|------|------|
| `client version 1.43 is too old` | Docker 버전 불일치 | CI 이미지를 `docker:27`로 업그레이드 |
| `http: server gave HTTP response to HTTPS client` | containerd가 HTTPS 사용 | `certs.d/hosts.toml` 설정 + containerd 재시작 |
| `dial tcp 192.168.5.8:80: no route to host` | 포트 80 접근 불가 | 포트 80 포워딩 추가 |
| `403 Forbidden` / `401 Unauthorized` | 인증 실패 | GitLab `external_url` 변경 + Secret 확인 |
| `connection refused` on `:80` | 포워딩 체인 불완전 | INPUT/FORWARD iptables 규칙 추가 |

### 디버깅 명령어

```bash
# containerd 로그 확인
ssh k8s-n1 'sudo journalctl -u containerd --since "5 min ago" | grep -i registry'

# Pod 이벤트 확인
kubectl describe pod -l app=api -n gition | grep -A5 "Events:"

# iptables 규칙 확인
sudo iptables -t nat -L PREROUTING -n -v
sudo iptables -L FORWARD -n -v
```

---

## ✅ 최종 결과

- GitLab CI/CD 파이프라인 정상 작동
- Docker 이미지 빌드 및 Registry 푸시 성공
- K8s에서 외부 GitLab Registry 이미지 Pull 성공
- containerd insecure registry 설정 완료

---

## 📚 참고

- [Day 1 - 인프라 구축](../day1-1224/install-3tier/README.md)
- [Day 2 - 애플리케이션 배포](../day2-1229/README.md)
- [Day 3 - 외부 GitLab Registry 연동](../day3-1230/README.md)
