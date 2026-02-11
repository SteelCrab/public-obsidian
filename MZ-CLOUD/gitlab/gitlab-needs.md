# GitLab Needs

#gitlab #cicd #needs #dag

---

DAG(Directed Acyclic Graph) 방식의 잡 의존성 정의.

## 기본 사용

```yaml
build:
  stage: build
  script: npm run build

test:
  stage: test
  needs: [build]
  script: npm test
```

## 스테이지 무시

`needs`를 사용하면 스테이지 순서와 관계없이 실행 가능.

```yaml
stages:
  - build
  - test
  - deploy

deploy_staging:
  stage: deploy
  needs: [build]  # test 완료 안 기다림
  script: ./deploy.sh staging
```

## 아티팩트 제어

```yaml
test:
  needs:
    - job: build
      artifacts: true  # 기본값
```

아티팩트 없이:

```yaml
test:
  needs:
    - job: build
      artifacts: false
```

## 빈 needs

이전 스테이지 기다리지 않고 즉시 실행.

```yaml
lint:
  stage: test
  needs: []
  script: npm run lint
```

## 병렬 잡 참조

```yaml
build:
  parallel: 3
  script: ./build.sh

test:
  needs:
    - job: build
      parallel:
        matrix:
          - RUNNER: [1, 2, 3]
```
