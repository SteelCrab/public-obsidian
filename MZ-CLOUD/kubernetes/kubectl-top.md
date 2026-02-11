# Kubectl 리소스 사용량

#kubernetes #kubectl #top #모니터링

---

CPU/메모리 사용량 확인. (metrics-server 필요)

| 명령어 | 설명 |
|--------|------|
| `kubectl top nodes` | 노드 리소스 사용량 |
| `kubectl top pods` | Pod 리소스 사용량 |
| `kubectl top pods -A` | 모든 네임스페이스 |
| `kubectl top pods --containers` | 컨테이너별 사용량 |
| `kubectl top pods -l app=nginx` | 레이블로 필터 |
