#!/bin/bash
# =============================================================================
# Kubernetes 클러스터 전체 상태 확인 스크립트
# 사용법: ./check-cluster.sh
# =============================================================================

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================="
echo "🔍 Kubernetes 클러스터 상태 점검"
echo "   $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================================="

# 1. 노드 상태
echo -e "\n${YELLOW}=== 1. 노드 상태 ===${NC}"
kubectl get nodes -o wide
NOT_READY=$(kubectl get nodes --no-headers | grep -v "Ready" | wc -l)
if [ "$NOT_READY" -gt 0 ]; then
    echo -e "${RED}⚠️  NotReady 노드: $NOT_READY${NC}"
else
    echo -e "${GREEN}✅ 모든 노드 Ready${NC}"
fi

# 2. kube-system Pod 상태
echo -e "\n${YELLOW}=== 2. kube-system Pod 상태 ===${NC}"
kubectl get pods -n kube-system --no-headers | grep -v "Running" | grep -v "Completed" || echo -e "${GREEN}✅ 모든 kube-system Pod 정상${NC}"

# 3. CoreDNS 상태
echo -e "\n${YELLOW}=== 3. CoreDNS 상태 ===${NC}"
kubectl get pods -n kube-system -l k8s-app=kube-dns

# 4. Calico 상태
echo -e "\n${YELLOW}=== 4. Calico CNI 상태 ===${NC}"
kubectl get pods -n kube-system -l k8s-app=calico-node -o wide
kubectl get pods -n kube-system -l k8s-app=calico-kube-controllers

# 5. MetalLB 상태
echo -e "\n${YELLOW}=== 5. MetalLB 상태 ===${NC}"
kubectl get pods -n metallb-system 2>/dev/null || echo "MetalLB 미설치"

# 6. Ingress-Nginx 상태
echo -e "\n${YELLOW}=== 6. Ingress-Nginx 상태 ===${NC}"
kubectl get pods -n ingress-nginx 2>/dev/null || echo "Ingress-Nginx 미설치"
kubectl get svc -n ingress-nginx 2>/dev/null | grep LoadBalancer || true

# 7. MySQL Operator 상태
echo -e "\n${YELLOW}=== 7. MySQL Operator 상태 ===${NC}"
kubectl get pods -n mysql-operator 2>/dev/null || echo "MySQL Operator 미설치"

# 8. MySQL InnoDB Cluster 상태
echo -e "\n${YELLOW}=== 8. MySQL InnoDB Cluster 상태 ===${NC}"
kubectl get innodbcluster -n gition 2>/dev/null || echo "InnoDBCluster 미생성"
kubectl get pods -n gition -l mysql.oracle.com/cluster=mysql-cluster 2>/dev/null || true

# 9. gition 애플리케이션 상태
echo -e "\n${YELLOW}=== 9. gition 애플리케이션 상태 ===${NC}"
kubectl get pods -n gition 2>/dev/null || echo "gition namespace 없음"

# 10. 문제 Pod 목록 (전체 클러스터)
echo -e "\n${YELLOW}=== 10. 문제 Pod 목록 (NotRunning) ===${NC}"
PROBLEM_PODS=$(kubectl get pods -A --no-headers 2>/dev/null | grep -v "Running" | grep -v "Completed" | wc -l)
if [ "$PROBLEM_PODS" -gt 0 ]; then
    echo -e "${RED}⚠️  문제 Pod: $PROBLEM_PODS 개${NC}"
    kubectl get pods -A | grep -v "Running" | grep -v "Completed" | grep -v "NAMESPACE"
else
    echo -e "${GREEN}✅ 모든 Pod 정상${NC}"
fi

# 11. PV/PVC 상태
echo -e "\n${YELLOW}=== 11. PersistentVolume 상태 ===${NC}"
kubectl get pv 2>/dev/null | head -10 || echo "PV 없음"

echo -e "\n${YELLOW}=== 12. gition PVC 상태 ===${NC}"
kubectl get pvc -n gition 2>/dev/null || echo "PVC 없음"

# 요약
echo -e "\n=============================================="
echo -e "${YELLOW}📊 요약${NC}"
echo "=============================================="
echo "노드: $(kubectl get nodes --no-headers | wc -l)개"
echo "전체 Pod: $(kubectl get pods -A --no-headers 2>/dev/null | wc -l)개"
echo "문제 Pod: $PROBLEM_PODS개"
echo "=============================================="

if [ "$PROBLEM_PODS" -gt 0 ]; then
    echo -e "${RED}⚠️  클러스터에 문제가 있습니다. 위 목록을 확인하세요.${NC}"
else
    echo -e "${GREEN}✅ 클러스터 정상!${NC}"
fi
