# Kubernetes Service

#kubernetes #service #네트워킹

---

Pod 집합에 대한 안정적인 네트워크 엔드포인트를 제공하는 추상화 리소스.
Pod는 생성/삭제 시 IP가 바뀌지만, Service는 고정된 접근점을 유지한다.

---

## Service 타입

| 타입 | 설명 | 외부 접근 |
|------|------|----------|
| [[k8s-service-clusterip]] | 클러스터 내부 전용 가상 IP | X |
| [[k8s-service-nodeport]] | 노드 포트로 외부 노출 | O (NodeIP:Port) |
| [[k8s-service-loadbalancer]] | 클라우드 로드밸런서 자동 생성 | O (LB DNS) |
| `ExternalName` | 외부 DNS를 CNAME으로 매핑 | O (DNS) |

---

## 공통 구조

```yaml
apiVersion: v1
kind: Service
metadata:
  name: <서비스명>
spec:
  type: <ClusterIP|NodePort|LoadBalancer>
  selector:
    app: <라벨>        # 이 라벨을 가진 Pod로 트래픽 전달
  ports:
    - name: <포트명>
      protocol: TCP
      port: <서비스포트>       # Service가 받는 포트
      targetPort: <컨테이너포트> # Pod로 전달하는 포트
```

---

## selector 동작 원리

```
Service (selector: app=web)
    │
    ├──→ Pod (labels: app=web)  ✓ 매칭
    ├──→ Pod (labels: app=web)  ✓ 매칭
    └──✕ Pod (labels: app=api)  ✗ 불일치
```

> [!Note]
> `selector`의 라벨과 Deployment `template.metadata.labels`가 반드시 일치해야 한다.

---

## 관련 명령어

| 명령어 | 설명 |
|--------|------|
| `kubectl get svc` | Service 목록 조회 |
| `kubectl describe svc <이름>` | Service 상세 정보 |
| `kubectl get endpoints <이름>` | 연결된 Pod IP 확인 |
| `kubectl delete svc <이름>` | Service 삭제 |

---

## 관련 노트

- [[k8s-service-clusterip]] - ClusterIP 타입
- [[k8s-service-nodeport]] - NodePort 타입
- [[k8s-service-loadbalancer]] - LoadBalancer 타입
- [[kubectl-get]] - 리소스 조회
- [[kubectl-apply]] - 리소스 적용
