# GitLab CI/CD MOC

#gitlab #cicd #yaml #MOC

---

GitLab CI/CD 파이프라인 구성을 연결하는 허브 노트.

---

## 기본 구조

- [[gitlab-pipeline]] - 파이프라인 기본
- [[gitlab-stages]] - 스테이지 정의
- [[gitlab-jobs]] - 잡 구성
- [[gitlab-scripts]] - 스크립트 (before_script, script, after_script)

---

## 실행 환경

- [[gitlab-runners]] - 러너 설정
- [[gitlab-variables]] - 변수
- [[gitlab-image]] - Docker 이미지
- [[gitlab-services]] - 서비스 컨테이너

---

## 흐름 제어

- [[gitlab-rules]] - 규칙 (rules)
- [[gitlab-only-except]] - only/except (레거시)
- [[gitlab-needs]] - 잡 의존성
- [[gitlab-dependencies]] - 아티팩트 의존성
- [[gitlab-when]] - 실행 조건

---

## 데이터 관리

- [[gitlab-artifacts]] - 아티팩트
- [[gitlab-cache]] - 캐싱
- [[gitlab-include]] - 외부 파일 포함

---

## 배포

- [[gitlab-environments]] - 환경 정의
- [[gitlab-deploy]] - 배포 잡
- [[gitlab-review-apps]] - 리뷰 앱

---

## Docker

- [[gitlab-container-registry]] - 컨테이너 레지스트리
- [[gitlab-docker-build]] - Docker 빌드

---

## 빠른 참조

```yaml
stages:
  - build
  - test
  - deploy

variables:
  APP_NAME: "myapp"

build:
  stage: build
  image: node:20
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - dist/

test:
  stage: test
  script:
    - npm test

deploy:
  stage: deploy
  script:
    - echo "Deploying..."
  only:
    - main
```

---

## 외부 링크

- [GitLab CI/CD 문서](https://docs.gitlab.com/ee/ci/)
- [.gitlab-ci.yml 레퍼런스](https://docs.gitlab.com/ee/ci/yaml/)
- [CI/CD 키워드](https://docs.gitlab.com/ee/ci/yaml/index.html)

---

*Zettelkasten 스타일로 구성됨*
