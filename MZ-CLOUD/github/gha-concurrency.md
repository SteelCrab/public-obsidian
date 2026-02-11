# GitHub Actions 동시성 제어

#github #actions #concurrency

---

동시 실행 제한.

## 워크플로우 레벨

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

## 잡 레벨

```yaml
jobs:
  deploy:
    concurrency:
      group: deploy-${{ github.ref }}
      cancel-in-progress: false
```

## 환경별 제한

```yaml
jobs:
  deploy:
    environment: production
    concurrency: production
    steps:
      - run: ./deploy.sh
```

## 일반적인 패턴

```yaml
# PR마다 하나의 워크플로우만 실행
concurrency:
  group: ${{ github.workflow }}-${{ github.head_ref || github.run_id }}
  cancel-in-progress: true

# 브랜치별 배포 잠금
concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: false
```
