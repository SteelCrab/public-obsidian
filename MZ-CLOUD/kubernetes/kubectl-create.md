# Kubectl 리소스 생성

#kubernetes #kubectl #create

---

명령형 리소스 생성.

| 명령어 | 설명 |
|--------|------|
| `kubectl create -f <파일>` | 파일로 생성 |
| `kubectl create namespace <이름>` | 네임스페이스 생성 |
| `kubectl create deployment <이름> --image=<이미지>` | 디플로이먼트 생성 |
| `kubectl create secret generic <이름> --from-literal=key=value` | 시크릿 생성 |
| `kubectl create configmap <이름> --from-file=<파일>` | ConfigMap 생성 |
| `kubectl run <이름> --image=<이미지>` | Pod 생성 |
| `kubectl expose deploy <이름> --port=80` | 서비스 노출 |
