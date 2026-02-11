# Kubectl 컨텍스트 설정

#kubernetes #kubectl #config #컨텍스트

---

kubeconfig 및 컨텍스트 관리.

| 명령어 | 설명 |
|--------|------|
| `kubectl config view` | 설정 보기 |
| `kubectl config current-context` | 현재 컨텍스트 |
| `kubectl config get-contexts` | 컨텍스트 목록 |
| `kubectl config use-context <이름>` | 컨텍스트 전환 |
| `kubectl config set-context --current --namespace=<ns>` | 기본 네임스페이스 설정 |
