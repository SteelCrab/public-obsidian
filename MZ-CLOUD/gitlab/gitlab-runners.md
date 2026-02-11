# GitLab 러너

#gitlab #cicd #runner

---

CI/CD 잡을 실행하는 에이전트.

## 러너 유형

| 유형 | 설명 |
|------|------|
| Shared | GitLab.com 공유 러너 |
| Group | 그룹 전용 |
| Project | 프로젝트 전용 |

## 태그로 러너 지정

```yaml
job:
  tags:
    - docker
    - linux
  script:
    - echo "Running on tagged runner"
```

## Executor 유형

| Executor | 설명 |
|----------|------|
| `shell` | 셸에서 직접 실행 |
| `docker` | Docker 컨테이너에서 실행 |
| `kubernetes` | K8s 파드에서 실행 |
| `docker-machine` | 자동 스케일링 |

## 러너 등록

```bash
gitlab-runner register \
  --url https://gitlab.com/ \
  --registration-token TOKEN
```

## 러너 상태 확인

```bash
gitlab-runner status
gitlab-runner list
```
