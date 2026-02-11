# Kubectl 리소스 조회

#kubernetes #kubectl #get

---

리소스 목록 조회.

| 명령어 | 설명 |
|--------|------|
| `kubectl get pods` | Pod 목록 |
| `kubectl get pods -o wide` | Pod 상세 목록 |
| `kubectl get pods -w` | 실시간 감시 |
| `kubectl get all` | 모든 리소스 |
| `kubectl get svc` | 서비스 목록 |
| `kubectl get deploy` | 디플로이먼트 목록 |
| `kubectl get ns` | 네임스페이스 목록 |
| `kubectl get pods -n <ns>` | 특정 네임스페이스 |
| `kubectl get pods -A` | 모든 네임스페이스 |
| `kubectl get pods -o yaml` | YAML 출력 |
| `kubectl get pods -o json` | JSON 출력 |
| `kubectl get pods -l app=nginx` | 레이블 필터 |
