# GitHub Actions Docker 로그인

#github #actions #docker #login

---

컨테이너 레지스트리 인증.

## Docker Hub

```yaml
steps:
  - uses: docker/login-action@v3
    with:
      username: ${{ secrets.DOCKERHUB_USERNAME }}
      password: ${{ secrets.DOCKERHUB_TOKEN }}
```

## GitHub Container Registry (ghcr.io)

```yaml
steps:
  - uses: docker/login-action@v3
    with:
      registry: ghcr.io
      username: ${{ github.actor }}
      password: ${{ secrets.GITHUB_TOKEN }}
```

## AWS ECR

```yaml
steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
      aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      aws-region: ap-northeast-2

  - uses: docker/login-action@v3
    with:
      registry: 123456789.dkr.ecr.ap-northeast-2.amazonaws.com
```

## 전체 예시

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:latest
```

| 레지스트리      | registry 값                                 |
| ---------- | ------------------------------------------ |
| Docker Hub | (생략)                                       |
| GitHub     | `ghcr.io`                                  |
| AWS ECR    | `<account>.dkr.ecr.<region>.amazonaws.com` |
| GCP GCR    | `gcr.io`                                   |
| Azure ACR  | `<name>.azurecr.io`                        |
