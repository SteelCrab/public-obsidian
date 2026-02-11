# Kubectl 포트 포워딩

#kubernetes #kubectl #port-forward

---

로컬에서 클러스터 리소스 접근.

| 명령어 | 설명 |
|--------|------|
| `kubectl port-forward pod/<pod> 8080:80` | Pod 포트 포워딩 |
| `kubectl port-forward svc/<서비스> 8080:80` | 서비스 포트 포워딩 |
| `kubectl port-forward deploy/<디플로이> 8080:80` | 디플로이먼트 포트 포워딩 |
| `kubectl port-forward pod/<pod> 8080:80 --address 0.0.0.0` | 외부 접근 허용 |
