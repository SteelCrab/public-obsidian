# Day 5 - K8s Health Check 및 MySQL DNS 설정 (01/01)

> Health Check 간격 최적화 및 StatefulSet DNS 문제 해결

## 📋 목차

1. [개요](#-개요)
2. [Health Check 변경](#-변경-내용)
3. [적용 방법](#-적용-방법)
4. [빌드 및 배포](#-빌드-및-배포-방법)
5. [API-DB 연동 테스트](#-api-db-연동-테스트)
6. [MySQL DNS 문제 해결](#-mysql-dns-문제-해결)
7. [참고](#-참고)

---

## 📌 개요

### 배경

K8s의 `livenessProbe`, `readinessProbe`가 너무 자주 실행되어 불필요한 리소스를 소모하고 있었습니다.

### 변경 전 → 후 상태

```yaml
livenessProbe:
  periodSeconds: 10   # 10초마다 체크
readinessProbe:
  periodSeconds: 5    # 5초마다 체크
```

**문제점:**
- 개인 프로젝트에서 과도한 Health Check
- 로그에 `/health` 요청이 지속적으로 기록

---

## 🔧 변경 내용

### fastapi-deployment.yaml

| 항목 | 변경 전 | 변경 후 |
|------|---------|---------| 
| `livenessProbe.initialDelaySeconds` | 10 | 30 |
| `livenessProbe.periodSeconds` | 10 | 60 |
| `readinessProbe.initialDelaySeconds` | 5 | 15 |
| `readinessProbe.periodSeconds` | 5 | 60 |

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3001
  initialDelaySeconds: 30
  periodSeconds: 60
readinessProbe:
  httpGet:
    path: /health
    port: 3001
  initialDelaySeconds: 15
  periodSeconds: 60
```

> [!NOTE]
> **Probe 제거 옵션**: 개인 프로젝트에서는 Probe를 완전히 제거해도 됩니다.

---

## 🏢 적용 방법

```bash
kubectl apply -f personal-project/day2-1229/k8s/fastapi-deployment.yaml
kubectl rollout status deployment api -n gition
```

### 확인

```bash
kubectl describe deployment api -n gition | grep -A5 "Liveness\|Readiness"
```

---

## 🔄 빌드 및 배포 방법

### 1. GitLab CI/CD 자동 빌드

`main` 브랜치에 푸시하면 자동으로 빌드됩니다.

```bash
git add .
git commit -m "feat: update deployment"
git push origin main
```

**GitLab CI 파이프라인:**
1. `build-frontend` → Docker 이미지 빌드 → Registry 푸시
2. `build-backend` → Docker 이미지 빌드 → Registry 푸시

### 2. K8s 배포

```bash
# Deployment 적용
kubectl apply -f fastapi-deployment.yaml
kubectl apply -f react-deployment.yaml


# 롤아웃 상태 확인
kubectl rollout status deployment api -n gition
kubectl rollout status deployment react -n gition
```

### 3. 이미지 수동 Pull (새 이미지 강제 적용)

```bash
kubectl rollout restart deployment api -n gition
kubectl rollout restart deployment react -n gition
```

### 4. 확인

```bash
kubectl get pods -n gition
kubectl logs -l app=api -n gition --tail=20
```

---

## 🔗 API-DB 연동 테스트

### 1. 로그에서 DB 접속 확인

```bash
kubectl logs -l app=api -n gition | grep -i "database\|pool"
```

**성공 시:**
```
Database pool initialized
```

**실패 시:**
```
Failed to initialize database pool: (2003, "Can't connect to MySQL server...")
```

### 2. MySQL 직접 확인

```bash
# MySQL Pod에서 DB 확인
kubectl exec -it mysql-0 -n gition -- mysql -u pista -p -e "SHOW DATABASES;"

# gition 데이터베이스가 있어야 함
```

### 3. API Health Check

```bash
kubectl port-forward svc/api-svc 3001:3001 -n gition &
curl http://localhost:3001/health
```

**응답:**
```json
{"status":"ok","github_configured":false}
```

---

## 🗄️ MySQL DNS 문제 해결

### 문제

```
ERROR: Can't connect to MySQL server on 'mysql-0.mysql-read.gition.svc.cluster.local'
```

### 원인

StatefulSet의 `serviceName`과 Headless Service 이름 불일치

| 항목 | 기존 값 | 올바른 값 |
|------|---------|----------|
| StatefulSet `serviceName` | `mysql` | `mysql-read` |
| Headless Service 이름 | `mysql-read` | `mysql-read` |

StatefulSet Pod의 DNS 형식:
```
<pod-name>.<serviceName>.<namespace>.svc.cluster.local
```

### 해결

`mysql-slave.yaml`에서 `serviceName` 수정:

```yaml
spec:
  serviceName: mysql-read  # mysql → mysql-read
```

### 적용

```bash
kubectl apply -f personal-project/day2-1229/k8s/mysql-slave.yaml

# DNS 테스트
kubectl run test-dns --image=busybox -n gition --rm -it --restart=Never -- nslookup mysql-read
```

### Deployment MYSQL_HOST 변경

```yaml
env:
- name: MYSQL_HOST
  value: "mysql-read"  # 로드밸런싱
# 또는
  value: "mysql-0.mysql-read"  # 특정 Pod
```

---

## 📚 참고

- [Day 4 - GitLab CI/CD 및 Containerd 설정](../day4-1231/README.md)
