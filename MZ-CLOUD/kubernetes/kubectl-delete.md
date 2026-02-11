# Kubectl 리소스 삭제

#kubernetes #kubectl #delete

---

리소스 삭제.

| 명령어 | 설명 |
|--------|------|
| `kubectl delete pod <이름>` | Pod 삭제 |
| `kubectl delete -f <파일>` | 파일로 삭제 |
| `kubectl delete deploy <이름>` | 디플로이먼트 삭제 |
| `kubectl delete svc <이름>` | 서비스 삭제 |
| `kubectl delete ns <이름>` | 네임스페이스 삭제 |
| `kubectl delete pods --all` | 모든 Pod 삭제 |
| `kubectl delete pods -l app=nginx` | 레이블로 삭제 |
| `kubectl delete pod <이름> --force --grace-period=0` | 강제 삭제 |
