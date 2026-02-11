# Service - LoadBalancer

#kubernetes #service #LoadBalancer #네트워킹

---

클라우드 프로바이더(AWS, GCP 등)의 **로드밸런서를 자동으로 생성**하여 외부 트래픽을 받는 Service 타입.
`NodePort`와 `ClusterIP` 기능을 모두 포함한다.

---

## 아키텍처

```
 사용자 (외부)
    │
    ▼ <LB DNS>:80
┌──────────────────────┐
│  Cloud Load Balancer │  ← 클라우드가 자동 생성 (NLB/CLB)
└──────────┬───────────┘
           │
    ┌──────┼──────┐
    ▼      ▼      ▼
  Node   Node   Node         ← NodePort로 수신
    │      │      │
    ▼      ▼      ▼
  Service (LoadBalancer)      ← ClusterIP + NodePort 포함
    │
  ┌─┼──┐
  ▼ ▼  ▼
 Pod Pod Pod
```

---

## 예시

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "external"
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "instance"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
    - name: http
      port: 80
      targetPort: 80
      protocol: TCP
```

> [!Note]
> AWS에서는 `annotations`으로 NLB/ALB 동작을 세부 설정한다.
> AWS Load Balancer Controller 설치 시 더 세밀한 제어가 가능하다.

---

## Service 타입 전체 비교

| 항목 | ClusterIP | NodePort | LoadBalancer |
|------|-----------|----------|-------------|
| 외부 접근 | X | O (`NodeIP:Port`) | O (LB DNS) |
| 하위 타입 포함 | - | ClusterIP | ClusterIP + NodePort |
| 클라우드 LB 생성 | X | X | O (자동) |
| 비용 | 무료 | 무료 | LB 비용 발생 |
| 사용 환경 | 내부 통신 | 개발/테스트 | 프로덕션 |

---

## 관련 노트

- [[k8s-service]] - Service 개요
- [[k8s-service-clusterip]] - ClusterIP 타입
- [[k8s-service-nodeport]] - NodePort 타입
- [[CICD_2026-02-09]] - EKS 멀티 컨테이너 배포 실습
