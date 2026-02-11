# GitLab 배포

#gitlab #cicd #deploy

---

CI/CD 파이프라인의 배포 잡 구성.

## 기본 배포

```yaml
deploy:
  stage: deploy
  script:
    - ./deploy.sh
  environment:
    name: production
```

## SSH 배포

```yaml
deploy:
  stage: deploy
  before_script:
    - 'which ssh-agent || apt-get install -y openssh-client'
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
    - mkdir -p ~/.ssh
    - chmod 700 ~/.ssh
  script:
    - ssh $USER@$HOST "cd /app && git pull && docker-compose up -d"
  environment:
    name: production
```

## Docker 배포

```yaml
deploy:
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker pull $CI_REGISTRY_IMAGE:latest
    - docker stop app || true
    - docker rm app || true
    - docker run -d --name app -p 8000:8000 $CI_REGISTRY_IMAGE:latest
```

## 수동 승인

```yaml
deploy_prod:
  stage: deploy
  script: ./deploy.sh
  when: manual
  allow_failure: false
```

## 스테이징 → 프로덕션

```yaml
deploy_staging:
  stage: deploy
  script: ./deploy.sh staging
  environment:
    name: staging

deploy_production:
  stage: deploy
  script: ./deploy.sh production
  environment:
    name: production
  when: manual
  needs: [deploy_staging]
```
