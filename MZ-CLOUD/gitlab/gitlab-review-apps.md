# GitLab 리뷰 앱

#gitlab #cicd #review-apps

---

Merge Request별로 임시 환경을 자동 생성.

## 기본 구조

```yaml
deploy_review:
  stage: deploy
  script:
    - ./deploy.sh $CI_COMMIT_REF_SLUG
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    url: https://$CI_COMMIT_REF_SLUG.example.com
    on_stop: stop_review
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"

stop_review:
  stage: deploy
  script:
    - ./stop.sh $CI_COMMIT_REF_SLUG
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    action: stop
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      when: manual
```

## 자동 중지

```yaml
deploy_review:
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    auto_stop_in: 1 day
    on_stop: stop_review
```

## Kubernetes 리뷰 앱

```yaml
deploy_review:
  image: bitnami/kubectl
  script:
    - kubectl apply -f k8s/review/
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    url: https://$CI_COMMIT_REF_SLUG.k8s.example.com
```

## 활용

| 용도 | 설명 |
|------|------|
| 코드 리뷰 | 실제 환경에서 변경 확인 |
| QA 테스트 | 독립 환경에서 테스트 |
| 스테이크홀더 리뷰 | 비개발자도 확인 가능 |
