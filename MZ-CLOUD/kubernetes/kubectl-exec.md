# Kubectl 컨테이너 접속

#kubernetes #kubectl #exec

---

컨테이너 내부 접속 및 명령 실행.

| 명령어 | 설명 |
|--------|------|
| `kubectl exec -it <pod> -- /bin/bash` | 쉘 접속 |
| `kubectl exec -it <pod> -- /bin/sh` | sh 접속 |
| `kubectl exec <pod> -- <명령어>` | 명령어 실행 |
| `kubectl exec -it <pod> -c <컨테이너> -- /bin/bash` | 특정 컨테이너 |
