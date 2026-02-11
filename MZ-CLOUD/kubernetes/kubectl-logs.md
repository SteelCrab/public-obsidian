# Kubectl 로그 확인

#kubernetes #kubectl #logs

---

컨테이너 로그 조회.

| 명령어 | 설명 |
|--------|------|
| `kubectl logs <pod>` | 로그 확인 |
| `kubectl logs -f <pod>` | 실시간 로그 |
| `kubectl logs --tail=100 <pod>` | 최근 100줄 |
| `kubectl logs <pod> -c <컨테이너>` | 특정 컨테이너 |
| `kubectl logs -p <pod>` | 이전 컨테이너 로그 |
| `kubectl logs -l app=nginx` | 레이블로 조회 |
| `kubectl logs --since=1h <pod>` | 최근 1시간 |
