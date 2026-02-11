# GitHub Actions Docker 빌드

#github #actions #docker #build #push

---

Docker 이미지 빌드 및 푸시.

## Buildx 설정

```yaml
- uses: docker/setup-buildx-action@v3
```

## 빌드 및 푸시

```yaml
- uses: docker/build-push-action@v6
  with:
    context: .
    push: true
    tags: username/app:latest
```

## 전체 예시

```yaml
steps:
  - uses: actions/checkout@v4

  - uses: docker/login-action@v3
    with:
      username: ${{ secrets.DOCKER_USERNAME }}
      password: ${{ secrets.DOCKER_PAT }}

  - uses: docker/setup-buildx-action@v3

  - uses: docker/build-push-action@v6
    with:
      context: .
      push: true
      tags: ${{ secrets.DOCKER_USERNAME }}/app:latest
```

## 태그 전략

```yaml
- uses: docker/build-push-action@v6
  with:
    context: .
    push: true
    tags: |
      username/app:latest
      username/app:${{ github.sha }}
      username/app:v1.0.0
```

## 옵션

| 옵션 | 설명 |
|------|------|
| `context` | 빌드 컨텍스트 경로 |
| `file` | Dockerfile 경로 |
| `push` | 푸시 여부 |
| `tags` | 이미지 태그 |
| `build-args` | 빌드 인자 |
| `platforms` | 멀티 플랫폼 (linux/amd64,linux/arm64) |
| `cache-from` | 캐시 소스 |
| `cache-to` | 캐시 저장 |

## 멀티 플랫폼 빌드

```yaml
- uses: docker/setup-qemu-action@v3

- uses: docker/setup-buildx-action@v3

- uses: docker/build-push-action@v6
  with:
    context: .
    platforms: linux/amd64,linux/arm64
    push: true
    tags: username/app:latest
```

## 캐시 사용

```yaml
- uses: docker/build-push-action@v6
  with:
    context: .
    push: true
    tags: username/app:latest
    cache-from: type=gha
    cache-to: type=gha,mode=max
```
