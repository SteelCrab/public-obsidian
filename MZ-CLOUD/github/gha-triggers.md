# GitHub Actions 트리거

#github #actions #on #trigger

---

워크플로우 실행 조건.

## 기본 이벤트

```yaml
on: push
on: [push, pull_request]
```

## 브랜치/태그 필터

```yaml
on:
  push:
    branches:
      - main
      - 'feature/**'
    tags:
      - 'v*'
    paths:
      - 'src/**'
    paths-ignore:
      - '**.md'
```

## Pull Request

```yaml
on:
  pull_request:
    branches: [main]
    types: [opened, synchronize, reopened]
```

## 수동 실행

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: '배포 환경'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production
```

## 스케줄

```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # 매일 자정 UTC
```

## 다른 워크플로우 호출

```yaml
on:
  workflow_call:
    inputs:
      config:
        required: true
        type: string
```
