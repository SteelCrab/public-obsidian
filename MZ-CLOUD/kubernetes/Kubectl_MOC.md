# Kubectl MOC

#kubernetes #kubectl #MOC #컨테이너오케스트레이션

---

Kubectl 명령어와 개념을 연결하는 허브 노트.

---

## 클러스터 정보

- [[kubectl-cluster-info]] - 클러스터 정보
- [[kubectl-config]] - 컨텍스트 설정

---

## 리소스 조회

- [[kubectl-get]] - 리소스 조회
- [[kubectl-describe]] - 리소스 상세
- [[kubectl-logs]] - 로그 확인

---

## 리소스 생성/관리

- [[kubectl-apply]] - 리소스 적용
- [[kubectl-create]] - 리소스 생성
- [[kubectl-delete]] - 리소스 삭제
- [[kubectl-edit]] - 리소스 편집

---

## Pod 작업

- [[kubectl-exec]] - 컨테이너 접속
- [[kubectl-port-forward]] - 포트 포워딩
- [[kubectl-cp]] - 파일 복사

---

## 스케일링

- [[kubectl-scale]] - 레플리카 조정
- [[kubectl-rollout]] - 롤아웃 관리

---

## 디버깅

- [[kubectl-top]] - 리소스 사용량
- [[kubectl-events]] - 이벤트 조회

---

## 네트워킹 (Service)

- [[k8s-service]] - Service 개요
- [[k8s-service-clusterip]] - ClusterIP (클러스터 내부 전용)
- [[k8s-service-nodeport]] - NodePort (노드 포트 외부 노출)
- [[k8s-service-loadbalancer]] - LoadBalancer (클라우드 LB 자동 생성)

---

## 빠른 참조

| 상황 | 명령어 |
|------|--------|
| Pod 목록 | `kubectl get pods` |
| 모든 리소스 | `kubectl get all` |
| Pod 상세 | `kubectl describe pod <이름>` |
| 로그 확인 | `kubectl logs <pod>` |
| 컨테이너 접속 | `kubectl exec -it <pod> -- /bin/bash` |
| 리소스 적용 | `kubectl apply -f <파일>` |
| 리소스 삭제 | `kubectl delete -f <파일>` |
| 네임스페이스 지정 | `kubectl -n <ns> get pods` |

---

## 학습 기록

- [k8s-learning-log](./k8s-learning-log.md) - Kubernetes 학습 가이드 (day별)

---

## 외부 링크

- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

*Zettelkasten 스타일로 구성됨*
