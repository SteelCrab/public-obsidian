#!/bin/bash

# EKS 설치 스크립트 for macOS
# 실행 방법: chmod +x eks_install.sh && ./eks_install.sh

set -e

echo "=================================="
echo "EKS 도구 설치 시작 (macOS)"
echo "=================================="

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 아키텍처 감지
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    echo -e "${GREEN}Apple Silicon 감지됨${NC}"
    KUBECTL_ARCH="arm64"
else
    echo -e "${GREEN}Intel 프로세서 감지됨${NC}"
    KUBECTL_ARCH="amd64"
fi

# Homebrew 설치 확인
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew가 설치되어 있지 않습니다. 설치 중...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo -e "${GREEN}✓ Homebrew가 이미 설치되어 있습니다.${NC}"
fi

# 1. kubectl 설치
echo ""
echo "1. kubectl 설치 중..."
if command -v kubectl &> /dev/null; then
    echo -e "${GREEN}✓ kubectl가 이미 설치되어 있습니다. ($(kubectl version --client --short 2>/dev/null || kubectl version --client))${NC}"
else
    brew install kubectl
    echo -e "${GREEN}✓ kubectl 설치 완료${NC}"
fi

# 2. AWS CLI 설치
echo ""
echo "2. AWS CLI 설치 중..."
if command -v aws &> /dev/null; then
    echo -e "${GREEN}✓ AWS CLI가 이미 설치되어 있습니다. ($(aws --version))${NC}"
else
    brew install awscli
    echo -e "${GREEN}✓ AWS CLI 설치 완료${NC}"
fi

# 3. eksctl 설치
echo ""
echo "3. eksctl 설치 중..."
if command -v eksctl &> /dev/null; then
    echo -e "${GREEN}✓ eksctl이 이미 설치되어 있습니다. ($(eksctl version))${NC}"
else
    brew tap weaveworks/tap
    brew install weaveworks/tap/eksctl
    echo -e "${GREEN}✓ eksctl 설치 완료${NC}"
fi

# 4. Helm 설치
echo ""
echo "4. Helm 설치 중..."
if command -v helm &> /dev/null; then
    echo -e "${GREEN}✓ Helm이 이미 설치되어 있습니다. ($(helm version --short))${NC}"
else
    brew install helm
    echo -e "${GREEN}✓ Helm 설치 완료${NC}"
fi

# 5. EKS Helm 차트 저장소 추가
echo ""
echo "5. EKS Helm 차트 저장소 추가 중..."
if helm repo list | grep -q "eks"; then
    echo -e "${YELLOW}EKS 저장소가 이미 추가되어 있습니다. 업데이트 중...${NC}"
    helm repo update eks
else
    helm repo add eks https://aws.github.io/eks-charts
    echo -e "${GREEN}✓ EKS Helm 차트 저장소 추가 완료${NC}"
fi

# 6. Helm 저장소 업데이트
echo ""
echo "6. Helm 저장소 업데이트 중..."
helm repo update
echo -e "${GREEN}✓ Helm 저장소 업데이트 완료${NC}"

# 7. kubectl 자동완성 설정 (선택사항)
echo ""
echo "7. kubectl 자동완성 설정 (선택사항)..."
SHELL_TYPE=$(basename "$SHELL")

if [ "$SHELL_TYPE" = "zsh" ]; then
    if ! grep -q "kubectl completion zsh" ~/.zshrc 2>/dev/null; then
        echo -e "${YELLOW}zsh용 kubectl 자동완성을 설정하시겠습니까? (y/n)${NC}"
        read -r response
        if [ "$response" = "y" ]; then
            echo 'source <(kubectl completion zsh)' >> ~/.zshrc
            echo 'alias k=kubectl' >> ~/.zshrc
            echo 'complete -F __start_kubectl k' >> ~/.zshrc
            echo -e "${GREEN}✓ kubectl 자동완성 설정 완료 (~/.zshrc)${NC}"
            echo -e "${YELLOW}변경사항 적용: source ~/.zshrc${NC}"
        fi
    else
        echo -e "${GREEN}✓ kubectl 자동완성이 이미 설정되어 있습니다.${NC}"
    fi
elif [ "$SHELL_TYPE" = "bash" ]; then
    if ! grep -q "kubectl completion bash" ~/.bash_profile 2>/dev/null; then
        echo -e "${YELLOW}bash용 kubectl 자동완성을 설정하시겠습니까? (y/n)${NC}"
        read -r response
        if [ "$response" = "y" ]; then
            brew install bash-completion@2
            echo 'source <(kubectl completion bash)' >> ~/.bash_profile
            echo 'alias k=kubectl' >> ~/.bash_profile
            echo 'complete -o default -F __start_kubectl k' >> ~/.bash_profile
            echo -e "${GREEN}✓ kubectl 자동완성 설정 완료 (~/.bash_profile)${NC}"
            echo -e "${YELLOW}변경사항 적용: source ~/.bash_profile${NC}"
        fi
    else
        echo -e "${GREEN}✓ kubectl 자동완성이 이미 설정되어 있습니다.${NC}"
    fi
fi

# 설치 확인
echo ""
echo "=================================="
echo "설치 완료 - 버전 확인"
echo "=================================="
echo ""
echo "kubectl version:"
kubectl version --client --short 2>/dev/null || kubectl version --client
echo ""
echo "aws version:"
aws --version
echo ""
echo "eksctl version:"
eksctl version
echo ""
echo "helm version:"
helm version --short
echo ""
echo "helm repos:"
helm repo list
echo ""

# AWS 설정 확인
echo "=================================="
echo "AWS 설정 확인"
echo "=================================="
if aws sts get-caller-identity &> /dev/null; then
    echo -e "${GREEN}✓ AWS 자격 증명이 올바르게 설정되어 있습니다.${NC}"
    aws sts get-caller-identity
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
echo "다음 단계:"
echo "1. AWS 자격 증명 설정 (아직 설정하지 않은 경우):"
echo "   aws configure"
echo ""
echo "2. EKS 클러스터에 연결:"
echo "   aws eks update-kubeconfig --region <region> --name <cluster-name>"
echo ""
echo "3. 클러스터 확인:"
echo "   kubectl cluster-info"
echo "   kubectl get nodes"
echo ""
echo "4. 유용한 Helm 차트:"
echo "   - AWS Load Balancer Controller:"
echo "     helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=<your-cluster>"
echo "   - EBS CSI Driver:"
echo "     helm install aws-ebs-csi-driver eks/aws-ebs-csi-driver -n kube-system"
echo ""
