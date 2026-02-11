#!/bin/bash

# EKS 설치 스크립트 for Linux (Ubuntu/Debian)
# 실행 방법: sudo ./eks_install_linux.sh
# 또는: curl -fsSL <script-url> | sudo bash

set -e

echo "=================================="
echo "EKS 도구 설치 시작 (Linux)"
echo "=================================="

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}이 스크립트는 root 권한이 필요합니다. sudo를 사용해주세요.${NC}"
    exit 1
fi

# 실제 사용자 확인 (sudo로 실행된 경우)
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

echo -e "${BLUE}설치 사용자: $ACTUAL_USER${NC}"
echo -e "${BLUE}홈 디렉토리: $ACTUAL_HOME${NC}"
echo ""

# 1. 패키지 업데이트 및 필수 도구 설치
echo ""
echo "1. 시스템 업데이트 및 필수 도구 설치 중..."
apt-get update -y
apt-get install -y \
    curl \
    unzip \
    net-tools \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    git \
    vim \
    jq
echo -e "${GREEN}✓ 필수 도구 설치 완료${NC}"

# 2. Docker 설치
echo ""
echo "2. Docker 설치 중..."
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker가 이미 설치되어 있습니다. ($(docker --version))${NC}"
else
    # Docker GPG 키 추가
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Docker 저장소 추가
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Docker 설치
    apt-get update -y
    apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    # Docker 서비스 시작 및 자동 시작 설정
    systemctl enable --now docker

    # 사용자를 docker 그룹에 추가
    usermod -aG docker $ACTUAL_USER

    # docker-compose 심볼릭 링크 생성
    if [ -f /usr/libexec/docker/cli-plugins/docker-compose ]; then
        ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
    fi

    echo -e "${GREEN}✓ Docker 설치 완료${NC}"
    echo -e "${YELLOW}⚠ Docker 그룹 적용을 위해 로그아웃 후 다시 로그인해주세요.${NC}"
fi

# 3. AWS CLI v2 설치
echo ""
echo "3. AWS CLI v2 설치 중..."
if command -v aws &> /dev/null; then
    echo -e "${GREEN}✓ AWS CLI가 이미 설치되어 있습니다. ($(aws --version))${NC}"
else
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    ./aws/install
    rm -rf awscliv2.zip aws/
    echo -e "${GREEN}✓ AWS CLI v2 설치 완료${NC}"
fi

# 4. kubectl 설치
echo ""
echo "4. kubectl 설치 중..."
if command -v kubectl &> /dev/null; then
    echo -e "${GREEN}✓ kubectl이 이미 설치되어 있습니다. ($(kubectl version --client --short 2>/dev/null || kubectl version --client))${NC}"
else
    # 최신 안정 버전 다운로드
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

    # 체크섬 검증
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

    # 설치
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl kubectl.sha256

    echo -e "${GREEN}✓ kubectl 설치 완료 (${KUBECTL_VERSION})${NC}"
fi

# 5. eksctl 설치
echo ""
echo "5. eksctl 설치 중..."
if command -v eksctl &> /dev/null; then
    echo -e "${GREEN}✓ eksctl이 이미 설치되어 있습니다. ($(eksctl version))${NC}"
else
    # 최신 버전 다운로드
    PLATFORM=$(uname -s)_amd64
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" | tar xz -C /tmp
    mv /tmp/eksctl /usr/local/bin
    chmod +x /usr/local/bin/eksctl
    echo -e "${GREEN}✓ eksctl 설치 완료${NC}"
fi

# 6. Helm 설치
echo ""
echo "6. Helm 설치 중..."
if command -v helm &> /dev/null; then
    echo -e "${GREEN}✓ Helm이 이미 설치되어 있습니다. ($(helm version --short))${NC}"
else
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo -e "${GREEN}✓ Helm 설치 완료${NC}"
fi

# 7. EKS Helm 차트 저장소 추가 (사용자 권한으로 실행)
echo ""
echo "7. EKS Helm 차트 저장소 추가 중..."
sudo -u $ACTUAL_USER bash << EOF
if helm repo list 2>/dev/null | grep -q "eks"; then
    echo -e "${YELLOW}EKS 저장소가 이미 추가되어 있습니다. 업데이트 중...${NC}"
    helm repo update eks
else
    helm repo add eks https://aws.github.io/eks-charts
    echo -e "${GREEN}✓ EKS Helm 차트 저장소 추가 완료${NC}"
fi
helm repo update
EOF

# 8. kubectl 자동완성 설정
echo ""
echo "8. kubectl 자동완성 설정 중..."
BASHRC_FILE="$ACTUAL_HOME/.bashrc"

if ! grep -q "kubectl completion bash" "$BASHRC_FILE" 2>/dev/null; then
    sudo -u $ACTUAL_USER bash << EOF
cat >> "$BASHRC_FILE" << 'BASHRC_END'

# kubectl 자동완성
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k

# eksctl 자동완성
source <(eksctl completion bash)
BASHRC_END
EOF
    echo -e "${GREEN}✓ kubectl 자동완성 설정 완료 ($BASHRC_FILE)${NC}"
    echo -e "${YELLOW}변경사항 적용: source ~/.bashrc${NC}"
else
    echo -e "${GREEN}✓ kubectl 자동완성이 이미 설정되어 있습니다.${NC}"
fi

# 9. kubeconfig 디렉토리 생성
echo ""
echo "9. kubeconfig 디렉토리 설정 중..."
KUBE_DIR="$ACTUAL_HOME/.kube"
if [ ! -d "$KUBE_DIR" ]; then
    mkdir -p "$KUBE_DIR"
    chown -R $ACTUAL_USER:$ACTUAL_USER "$KUBE_DIR"
    chmod 700 "$KUBE_DIR"
    echo -e "${GREEN}✓ kubeconfig 디렉토리 생성 완료${NC}"
else
    echo -e "${GREEN}✓ kubeconfig 디렉토리가 이미 존재합니다.${NC}"
fi

# 설치 확인
echo ""
echo "=================================="
echo "설치 완료 - 버전 확인"
echo "=================================="
echo ""
echo -e "${BLUE}Docker version:${NC}"
docker --version
echo ""
echo -e "${BLUE}AWS CLI version:${NC}"
aws --version
echo ""
echo -e "${BLUE}kubectl version:${NC}"
kubectl version --client --short 2>/dev/null || kubectl version --client
echo ""
echo -e "${BLUE}eksctl version:${NC}"
eksctl version
echo ""
echo -e "${BLUE}Helm version:${NC}"
helm version --short
echo ""
echo -e "${BLUE}Helm repos:${NC}"
sudo -u $ACTUAL_USER helm repo list
echo ""

# AWS 설정 확인
echo "=================================="
echo "AWS 설정 확인"
echo "=================================="
if sudo -u $ACTUAL_USER aws sts get-caller-identity &> /dev/null; then
    echo -e "${GREEN}✓ AWS 자격 증명이 올바르게 설정되어 있습니다.${NC}"
    sudo -u $ACTUAL_USER aws sts get-caller-identity
else
    echo -e "${YELLOW}⚠ AWS 자격 증명이 설정되어 있지 않습니다.${NC}"
    echo "다음 명령어로 AWS CLI를 설정하세요:"
    echo "  aws configure"
fi

echo ""
echo "=================================="
echo "설치 완료!"
echo "=================================="
echo ""
echo -e "${YELLOW}중요 사항:${NC}"
echo "1. Docker 그룹 적용을 위해 현재 세션을 종료하고 다시 로그인해주세요."
echo "   또는 다음 명령어를 실행하세요: newgrp docker"
echo ""
echo "2. 셸 자동완성을 활성화하려면 다음을 실행하세요:"
echo "   source ~/.bashrc"
echo ""
echo -e "${BLUE}다음 단계:${NC}"
echo ""
echo "1. AWS 자격 증명 설정 (아직 설정하지 않은 경우):"
echo "   aws configure"
echo "   또는 IAM Role을 사용하는 EC2 인스턴스의 경우 자동으로 설정됩니다."
echo ""
echo "2. EKS 클러스터에 연결:"
echo "   aws eks update-kubeconfig --region ap-northeast-2 --name <cluster-name>"
echo ""
echo "3. 클러스터 확인:"
echo "   kubectl cluster-info"
echo "   kubectl get nodes"
echo ""
echo "4. EKS 클러스터 생성 (새로 만드는 경우):"
echo "   eksctl create cluster \\"
echo "     --name my-cluster \\"
echo "     --region ap-northeast-2 \\"
echo "     --nodegroup-name standard-workers \\"
echo "     --node-type t3.medium \\"
echo "     --nodes 3 \\"
echo "     --nodes-min 1 \\"
echo "     --nodes-max 4 \\"
echo "     --managed"
echo ""
echo "5. 유용한 Helm 차트 설치:"
echo ""
echo "   a) AWS Load Balancer Controller:"
echo "      helm install aws-load-balancer-controller eks/aws-load-balancer-controller \\"
echo "        -n kube-system \\"
echo "        --set clusterName=<your-cluster-name>"
echo ""
echo "   b) AWS EBS CSI Driver:"
echo "      helm install aws-ebs-csi-driver eks/aws-ebs-csi-driver \\"
echo "        -n kube-system"
echo ""
echo "   c) AWS EFS CSI Driver:"
echo "      helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
echo "      helm install aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \\"
echo "        -n kube-system"
echo ""
echo "6. 클러스터 삭제 (필요한 경우):"
echo "   eksctl delete cluster --name my-cluster --region ap-northeast-2"
echo ""
