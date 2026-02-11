# Kubectl 리소스 편집

#kubernetes #kubectl #edit

---

실행 중인 리소스 편집.

| 명령어 | 설명 |
|--------|------|
| `kubectl edit pod <이름>` | Pod 편집 |
| `kubectl edit deploy <이름>` | 디플로이먼트 편집 |
| `kubectl edit svc <이름>` | 서비스 편집 |
| `kubectl edit configmap <이름>` | ConfigMap 편집 |
| `KUBE_EDITOR="nano" kubectl edit deploy <이름>` | 에디터 지정 |
