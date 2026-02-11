# GitLab Dependencies

#gitlab #cicd #dependencies #artifacts

---

아티팩트 다운로드 제어.

## 기본 동작

기본적으로 이전 스테이지의 모든 아티팩트를 다운로드.

## dependencies

특정 잡의 아티팩트만 다운로드.

```yaml
build:
  stage: build
  script: npm run build
  artifacts:
    paths:
      - dist/

test:
  stage: test
  dependencies:
    - build
  script: npm test
```

## 빈 dependencies

아티팩트 다운로드 안 함.

```yaml
lint:
  stage: test
  dependencies: []
  script: npm run lint
```

## needs vs dependencies

| 키워드 | 역할 |
|--------|------|
| `needs` | 실행 순서 + 아티팩트 |
| `dependencies` | 아티팩트만 |

## needs와 함께 사용

```yaml
test:
  needs:
    - job: build
      artifacts: false
  dependencies:
    - build
```

일반적으로 `needs`만 사용해도 충분.
