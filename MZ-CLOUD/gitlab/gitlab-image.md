# GitLab 이미지

#gitlab #cicd #docker #image

---

잡 실행에 사용할 Docker 이미지 지정.

## 기본 사용

```yaml
job:
  image: node:20
  script:
    - node --version
```

## 전역 이미지

```yaml
default:
  image: node:20

build:
  script: npm run build

test:
  script: npm test
```

## 이미지 옵션

```yaml
job:
  image:
    name: registry.example.com/image:tag
    entrypoint: [""]
```

## 프라이빗 레지스트리

```yaml
job:
  image: registry.example.com/private/image:tag
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
```

## GitLab Container Registry

```yaml
job:
  image: $CI_REGISTRY_IMAGE:latest
```

## 일반 이미지

| 이미지 | 용도 |
|--------|------|
| `node:20` | Node.js |
| `python:3.12` | Python |
| `golang:1.21` | Go |
| `docker:24` | Docker-in-Docker |
| `alpine:3.18` | 경량 Linux |
