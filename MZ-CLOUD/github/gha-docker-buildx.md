# GitHub Actions Docker Buildx

#github #actions #docker #buildx #build

---

Docker Buildx 빌더 설정 (멀티 플랫폼 빌드).

## docker/setup-buildx-action

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3
```

## 기본 워크플로우

```yaml
- uses: actions/checkout@v4

- uses: docker/setup-buildx-action@v3

- uses: docker/build-push-action@v6
  with:
    context: .
    push: true
    tags: user/app:latest
```

## 멀티 플랫폼 빌드

```yaml
- uses: docker/setup-buildx-action@v3

- uses: docker/build-push-action@v6
  with:
    platforms: linux/amd64,linux/arm64
    push: true
    tags: user/app:latest
```

## 캐시 설정

```yaml
- uses: docker/setup-buildx-action@v3

- uses: docker/build-push-action@v6
  with:
    context: .
    cache-from: type=gha
    cache-to: type=gha,mode=max
    push: true
    tags: user/app:latest
```

## 옵션

| 옵션 | 설명 |
|------|------|
| `version` | Buildx 버전 (기본: latest) |
| `driver` | 빌더 드라이버 (docker-container, kubernetes 등) |
| `install` | docker build 명령 대체 여부 |

## 장점

- 멀티 플랫폼 이미지 빌드 (ARM64, AMD64 등)
- 빌드 캐시 최적화
- 병렬 빌드 지원
- BuildKit 기능 활용
