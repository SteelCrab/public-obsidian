# GitLab Docker 빌드

#gitlab #cicd #docker #build

---

GitLab CI에서 Docker 이미지 빌드.

## Docker-in-Docker

```yaml
build:
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_HOST: tcp://docker:2376
    DOCKER_TLS_CERTDIR: "/certs"
  script:
    - docker build -t myapp .
```

## Kaniko (권장)

Docker 데몬 없이 빌드.

```yaml
build:
  image:
    name: gcr.io/kaniko-project/executor:v1.9.0-debug
    entrypoint: [""]
  script:
    - /kaniko/executor
      --context $CI_PROJECT_DIR
      --dockerfile $CI_PROJECT_DIR/Dockerfile
      --destination $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

## Buildx (멀티 아키텍처)

```yaml
build:
  image: docker:24
  services:
    - docker:24-dind
  before_script:
    - docker buildx create --use
  script:
    - docker buildx build
      --platform linux/amd64,linux/arm64
      --push
      -t $CI_REGISTRY_IMAGE:latest .
```

## 캐시 활용

```yaml
build:
  script:
    - docker pull $CI_REGISTRY_IMAGE:latest || true
    - docker build
      --cache-from $CI_REGISTRY_IMAGE:latest
      -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

## 전체 예시

```yaml
build:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE:latest
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker push $CI_REGISTRY_IMAGE:latest
```
