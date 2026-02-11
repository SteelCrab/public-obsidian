# GitHub OAuth Secret

> GitHub OAuth 인증에 필요한 Client ID/Secret을 저장하는 Kubernetes Secret

## 개요

| 항목 | 값 |
|------|-----|
| **Secret Name** | `github-secret` |
| **Namespace** | gition |
| **Type** | Opaque |

## Secret 키

| 키 | 설명 |
|----|------|
| `client-id` | GitHub OAuth App Client ID |
| `client-secret` | GitHub OAuth App Client Secret |

## 생성 방법

### 권장: kubectl 직접 생성

```bash
kubectl create secret generic github-secret -n gition \
  --from-literal=client-id='<YOUR_CLIENT_ID>' \
  --from-literal=client-secret='<YOUR_CLIENT_SECRET>'
```

### 또는 YAML 파일

```bash
# github-secret.yaml 수정 후
kubectl apply -f github-secret.yaml
```

> ⚠️ **주의**: YAML 파일에 직접 Secret을 넣으면 Git에 노출될 수 있음.  
> kubectl로 직접 생성하거나, `.gitignore`에 추가할 것.

## GitHub OAuth App 생성

1. GitHub → Settings → Developer settings → OAuth Apps → New OAuth App
2. 설정값:
   - **Application name**: `gition` (또는 원하는 이름)
   - **Homepage URL**: `http://gition.local`
   - **Authorization callback URL**: `http://gition.local/auth/callback`
3. 생성 후 Client ID와 Client Secret 복사

## 사용처

FastAPI 백엔드 Deployment에서 환경변수로 주입됨

```yaml
env:
- name: GITHUB_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: github-secret
      key: client-id
- name: GITHUB_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: github-secret
      key: client-secret
```

## 확인 명령어

```bash
# Secret 존재 확인
kubectl get secret github-secret -n gition

# Secret 내용 확인 (base64 디코딩)
kubectl get secret github-secret -n gition -o jsonpath='{.data.client-id}' | base64 -d
```
