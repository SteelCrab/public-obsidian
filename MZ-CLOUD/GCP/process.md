
## 프로세스
1. vpc 구성 
2. 방화벽 생성
3. subnet 생성 - private,public
4. 
5. 

## 구성 
### 1. VPC 생성 
| 변수         | 이름        |
| ---------- | --------- |
| <VPC_NAME> | pista-vpc |
|            |           |
```shell
gcloud compute networks create pista-vpc \
--subnet-mode=custom \
--bgp-routing-mode=regional

```
결과 
```shell
Created [https://www.googleapis.com/compute/v1/projects/named-foundry-486921-r5/global/networks/pista-vpc].
NAME       SUBNET_MODE  BGP_ROUTING_MODE  IPV4_RANGE  GATEWAY_IPV4  INTERNAL_IPV6_RANGE
pista-vpc  CUSTOM       REGIONAL
```
### 2. VPC 방화벽 규칙 설정
| 변수               | 이름             |
| ---------------- | -------------- |
| <FIREWALL_RULES> | pista-firewall |
SHELL
```shell
gcloud compute firewall-rules create pista-firewall --network pista-vpc --allow tcp:22,icmp
```
## 3. subnet 구성 
| 변수               | 이름             |
| ---------------- | -------------- |
| <FIREWALL_RULES> | pista-firewall |
|                  |                |
SHELL
```
# Public 서브넷 (웹 서버용)
gcloud compute networks subnets create pista-subnet-public \
    --network=pista-vpc \
    --region=asia-northeast3 \
    --range=10.0.1.0/24

# Private 서브넷 (DB용)
gcloud compute networks subnets create pista-subnet-private \
    --network=pista-vpc \
    --region=asia-northeast3 \
    --range=10.0.2.0/24 \
    --enable-private-ip-google-access
```


![[스크린샷 2026-02-11 오후 2.09.02.png]]
### 4. Cloud Router 구성 
shell
```bash
# Cloud Router 생성
gcloud compute routers create pista-router \
    --network=pista-vpc \
    --region=asia-northeast3

# Router 목록 확인
gcloud compute routers list
```
result
```
NAME          REGION           NETWORK
pista-router  asia-northeast3  pista-vpc
```
### 5. Cloud NAT 구성 
shell
```
gcloud compute routers nats create pista-nat \
    --router=pista-router \
    --region=asia-northeast3 \
    --nat-custom-subnet-ip-ranges=pista-subnet-private \
    --auto-allocate-nat-external-ips
```
check
```
gcloud compute routers nats list --router=pista-router \
    --region=asia-northeast3
```
