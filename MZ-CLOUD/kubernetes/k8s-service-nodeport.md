# Service - NodePort

#kubernetes #service #NodePort #네트워킹

---

모든 노드의 **고정 포트(30000~32767)** 를 열어 외부 트래픽을 받는 Service 타입.
`ClusterIP` 기능을 포함하며, 추가로 `<NodeIP>:<NodePort>`로 외부 접근이 가능하다.

---

## 아키텍처

```
 사용자 (외부)
    │
    ▼ <NodeIP>:<NodePort>
┌───────────────────────────────────┐
│         Node (EC2 Instance)       │
│                                   │
│   NodePort :31080 열림             │
│        │                          │
│        ▼                          │
│   Service (NodePort)              │
│   10.100.x.x:80                   │
│   = ClusterIP 기능 포함            │
│        │                          │
│   ┌────┼────┐                     │
│   ▼    ▼    ▼                     │
│  Pod  Pod  Pod                    │
│  :80  :80  :80                    │
└───────────────────────────────────┘
```

---

## ALB Ingress 연동 (target-type: instance)

Ingress를 통해 외부 노출 시, ALB가 **노드의 NodePort**를 경유하여 트래픽을 전달한다.

```
사용자 → ALB (internet-facing)
          │
          ▼
    ┌───────────┐
    │  Ingress  │  (ALB Controller)
    └─────┬─────┘
          │ target-type: instance
          ▼
     Node:NodePort        ← 모든 노드에 고정 포트 오픈
          │
   Service (NodePort)     ← ClusterIP 기능 포함
          │
     ┌────┼────┐
     ▼    ▼    ▼
    Pod  Pod  Pod          ← ALB → Node → Pod (2홉)
```

> [!Note]
> VPC CNI 없이도 동작하여 호환성이 높다.

---

## 예시

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - name: http
      port: 80             # Service 포트
      targetPort: 80       # Pod 컨테이너 포트
      nodePort: 31080      # 노드에서 열리는 포트 (생략 시 자동 할당)
```

> [!Note]
> `nodePort`를 생략하면 30000~32767 범위에서 자동 할당된다.

---

## 사용 시나리오

| 시나리오 | 설명 |
|----------|------|
| 개발/테스트 환경 | LB 없이 빠르게 외부 노출 |
| ALB + instance 모드 | ALB가 NodePort를 통해 트래픽 전달 |
| 온프레미스 환경 | 클라우드 LB 없이 외부 접근 필요 시 |

---

## ClusterIP vs NodePort

| 항목 | ClusterIP | NodePort |
|------|-----------|----------|
| 외부 접근 | X | O (`NodeIP:NodePort`) |
| 포트 범위 | 제한 없음 | 30000~32767 |
| ClusterIP 포함 | 자기 자신 | O (상위 호환) |
| ALB target-type | `ip` (Pod 직접) | `instance` (노드 경유) |
| 네트워크 홉 | 1홉 | 2홉 |
| VPC CNI 필수 | O | X |

---

## 관련 노트

- [[k8s-service]] - Service 개요
- [[k8s-service-clusterip]] - ClusterIP 타입 비교
- [[k8s-service-loadbalancer]] - LoadBalancer 타입 비교
- [[CICD_2026-02-09]] - EKS 멀티 컨테이너 배포 실습
