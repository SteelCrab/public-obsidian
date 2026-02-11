# GitHub Actions 조건

#github #actions #if #conditions

---

조건부 실행.

## 기본 문법

```yaml
jobs:
  deploy:
    if: github.ref == 'refs/heads/main'

steps:
  - name: Only on push
    if: github.event_name == 'push'
    run: echo "Pushed"
```

## 상태 함수

```yaml
steps:
  - name: Always run
    if: always()
    run: echo "Cleanup"

  - name: On success
    if: success()
    run: echo "Previous succeeded"

  - name: On failure
    if: failure()
    run: echo "Previous failed"

  - name: On cancel
    if: cancelled()
    run: echo "Cancelled"
```

## 표현식

```yaml
if: github.event_name == 'pull_request'
if: github.ref == 'refs/heads/main'
if: contains(github.event.head_commit.message, '[skip ci]') == false
if: startsWith(github.ref, 'refs/tags/')
if: github.actor == 'dependabot[bot]'
```

## 복합 조건

```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/main'
if: github.event_name == 'pull_request' || github.ref == 'refs/tags/*'
if: ${{ !cancelled() && needs.build.result == 'success' }}
```
