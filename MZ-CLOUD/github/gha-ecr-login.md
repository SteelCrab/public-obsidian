# GitHub Actions ECR 로그인

#github #actions #ecr #docker #aws

---

Amazon ECR 레지스트리 로그인.

## aws-actions/amazon-ecr-login

```yaml
- name: Login to Amazon ECR
  id: login-ecr
  uses: aws-actions/amazon-ecr-login@v2
```

## 전체 워크플로우

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_REGION }}

- name: Login to Amazon ECR
  id: login-ecr
  uses: aws-actions/amazon-ecr-login@v2

- name: Build and push
  env:
    ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
    ECR_REPOSITORY: my-app
    IMAGE_TAG: ${{ github.sha }}
  run: |
    docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
    docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
```

## 출력값

| 출력 | 설명 |
|------|------|
| `registry` | ECR 레지스트리 URI |
| `docker_username` | Docker 사용자명 (AWS) |
| `docker_password` | Docker 비밀번호 |

## 다중 레지스트리 로그인

```yaml
- name: Login to ECR
  uses: aws-actions/amazon-ecr-login@v2
  with:
    registries: "123456789012,987654321098"
```
