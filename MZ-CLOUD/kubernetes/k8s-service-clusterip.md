# Service - ClusterIP

#kubernetes #service #ClusterIP #네트워킹

---

클러스터 **내부 전용** 가상 IP를 부여하는 기본(default) Service 타입.
외부에서 직접 접근할 수 없고, 클러스터 내부의 다른 Pod나 Ingress를 통해서만 접근한다.

---

## 아키텍처

```
                  ┌─── 클러스터 내부 ───────────────────┐
                  │                                    │
 외부 접근 불가 ──✕──│→ Service (ClusterIP)               │
                  │   10.100.x.x:80                   │
                  │        │                           │
                  │   ┌────┼────┐                      │
                  │   ▼    ▼    ▼                      │
                  │  Pod  Pod  Pod                     │
                  │  :80  :80  :80                     │
                  └────────────────────────────────────┘
```

---

## ALB Ingress 연동 (target-type: ip)

Ingress를 통해 외부 노출 시, ALB가 **Pod IP로 직접** 트래픽을 전달한다.

```
사용자 → ALB (internet-facing)
          │
          ▼
    ┌───────────┐
    │  Ingress  │  (ALB Controller)
    └─────┬─────┘
          │ target-type: ip
          ▼
   Service (ClusterIP)   ← 클러스터 내부 가상 IP
          │
     ┌────┼────┐
     ▼    ▼    ▼
    Pod  Pod  Pod         ← ALB → Pod 직접 (1홉)
```

> [!Important]
> `target-type: ip`는 VPC CNI 환경이 완벽해야 동작한다.

---

## 예시

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  type: ClusterIP     # 생략 가능 (기본값)
  selector:
    app: web
  ports:
    - name: http
      port: 80         # Service 포트
      targetPort: 80   # Pod 컨테이너 포트
```

---

## 사용 시나리오

| 시나리오 | 설명 |
|----------|------|
| 내부 마이크로서비스 간 통신 | 프론트엔드 → 백엔드 API 호출 |
| Ingress 백엔드 | ALB/Nginx Ingress의 target으로 사용 |
| DB 접근 | 앱 Pod → DB Pod 연결 |

---

## 관련 노트

- [[k8s-service]] - Service 개요
- [[k8s-service-nodeport]] - NodePort 타입 비교
- [[k8s-service-loadbalancer]] - LoadBalancer 타입 비교
- [[CICD_2026-02-09]] - EKS 멀티 컨테이너 배포 실습
