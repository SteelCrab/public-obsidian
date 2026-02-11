# GitLab 서비스

#gitlab #cicd #services #docker

---

잡 실행 시 함께 시작되는 컨테이너 (데이터베이스, Redis 등).

## 기본 사용

```yaml
job:
  image: python:3.12
  services:
    - postgres:15
  variables:
    POSTGRES_DB: test
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password
  script:
    - pytest
```

## 서비스 접근

| 서비스 | 호스트명 |
|--------|----------|
| `postgres:15` | `postgres` |
| `redis:7` | `redis` |
| `mysql:8` | `mysql` |

## 서비스 별칭

```yaml
services:
  - name: postgres:15
    alias: db
```

접근: `db:5432`

## 일반 서비스

```yaml
services:
  - postgres:15
  - redis:7
  - elasticsearch:8
```

## Docker-in-Docker

```yaml
job:
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_HOST: tcp://docker:2376
    DOCKER_TLS_CERTDIR: "/certs"
  script:
    - docker build -t myapp .
```
