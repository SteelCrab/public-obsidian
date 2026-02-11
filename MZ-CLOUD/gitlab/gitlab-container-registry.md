# GitLab Container Registry

#gitlab #cicd #docker #registry

---

GitLab 내장 Docker 레지스트리.

## 레지스트리 주소

```
registry.gitlab.com/<namespace>/<project>
```

## 사전 정의 변수

| 변수 | 설명 |
|------|------|
| `CI_REGISTRY` | 레지스트리 URL |
| `CI_REGISTRY_IMAGE` | 프로젝트 이미지 경로 |
| `CI_REGISTRY_USER` | 레지스트리 사용자 |
| `CI_REGISTRY_PASSWORD` | 레지스트리 비밀번호 |

## 로그인

```yaml
before_script:
  - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
```

## 빌드 및 푸시

```yaml
build:
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

## 태그 전략

```yaml
script:
  - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
  - docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE:latest
  - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  - docker push $CI_REGISTRY_IMAGE:latest
```

## 이미지 사용

```yaml
deploy:
  image: $CI_REGISTRY_IMAGE:latest
  script:
    - ./deploy.sh
```
