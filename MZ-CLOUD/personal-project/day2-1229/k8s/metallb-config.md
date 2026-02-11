# MetalLB 설정

> Kubernetes LoadBalancer 서비스를 위한 베어메탈 로드밸런서

## 개요

MetalLB는 온프레미스 K8s 환경에서 LoadBalancer 타입 서비스를 사용할 수 있게 함

## IP Pool 설정

| 항목 | 값 |
|------|-----|
| **Pool Name** | ingress-pool |
| **IP 범위** | 172.100.100.20 - 172.100.100.30 |
| **모드** | L2 (ARP) |

## 배포

```bash
# MetalLB 설치 (이미 설치된 경우 스킵)
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

# IP Pool 및 L2 Advertisement 설정
kubectl apply -f metallb-config.yaml

# 확인
kubectl get ipaddresspools -n metallb-system
kubectl get l2advertisements -n metallb-system
```

## 동작 확인

```bash
# LoadBalancer 서비스에 IP 할당 확인
kubectl get svc -n ingress-nginx

# 결과 예시:
# NAME                       TYPE           EXTERNAL-IP
# ingress-nginx-controller   LoadBalancer   172.100.100.20
```

## 트러블슈팅

```bash
# MetalLB speaker 로그
kubectl logs -n metallb-system -l app=metallb -c speaker

# IPAddressPool 상태
kubectl describe ipaddresspool ingress-pool -n metallb-system
```
