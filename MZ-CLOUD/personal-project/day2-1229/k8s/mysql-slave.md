# MySQL Slave 설정

## 개요
K8s StatefulSet으로 배포되는 MySQL Slave (읽기 전용)

- **Master**: VM (172.100.100.11) - Docker Compose
- **Slave**: K8s StatefulSet (2 replicas) - 자동 복제 설정

## 사전 요구사항

### 1. mysql-secret 생성
```bash
kubectl create secret generic mysql-secret -n gition \
  --from-literal=root-password=<ROOT_PASSWORD> \
  --from-literal=user-password=<USER_PASSWORD> \
  --from-literal=repl-password=<REPL_PASSWORD>
```

### 2. Master에서 복제 계정 생성 (최초 1회)
```bash
# Master VM에서 실행
docker exec -it mysql-master mysql -uroot -p
```

```sql
CREATE USER 'repl_pista'@'%' IDENTIFIED WITH mysql_native_password BY '<REPL_PASSWORD>';
GRANT REPLICATION SLAVE ON *.* TO 'repl_pista'@'%';
FLUSH PRIVILEGES;
```

## 배포 명령
```bash
kubectl apply -f mysql-slave.yaml
```

## 구조

```
mysql-slave.yaml
├── ConfigMap (mysql-slave-config)
│   ├── my.cnf                 # MySQL 설정 (GTID 복제)
│   └── setup-replication.sh   # 자동 복제 설정 스크립트
├── StatefulSet (mysql-slave)
│   ├── initContainer          # server-id 동적 설정
│   ├── mysql container        # MySQL 서버
│   └── replication-setup      # 복제 설정 sidecar (자동 실행)
├── Service (mysql-read)       # Headless Service for Slave
└── Service (mysql-master)     # ExternalName → 172.100.100.11
```

## 자동 복제 설정

Pod가 시작되면 `replication-setup` sidecar가 자동으로:
1. MySQL이 준비될 때까지 대기
2. 복제 상태 확인 (이미 설정되어 있으면 스킵)
3. `CHANGE REPLICATION SOURCE TO ...` 실행
4. `START REPLICA` 실행

## 상태 확인

```bash
# Pod 상태
kubectl get pods -n gition -l role=slave

# Slave 복제 상태 확인
kubectl exec mysql-slave-0 -n gition -c mysql -- mysql -uroot -p<ROOT_PASSWORD> -e "SHOW REPLICA STATUS\G" | grep Running

# 두 Slave 모두 확인
for i in 0 1; do
  echo "=== mysql-slave-$i ==="
  kubectl exec mysql-slave-$i -n gition -c mysql -- mysql -uroot -p<ROOT_PASSWORD> -e "SHOW REPLICA STATUS\G" | grep -E "Replica_IO_Running|Replica_SQL_Running"
done
```

## 트러블슈팅

### 복제 상태가 No인 경우
```bash
# sidecar 로그 확인
kubectl logs mysql-slave-0 -n gition -c replication-setup

# 수동으로 복제 재설정
kubectl exec -it mysql-slave-0 -n gition -c mysql -- mysql -uroot -p<ROOT_PASSWORD>
```

```sql
STOP REPLICA;
RESET REPLICA ALL;
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='172.100.100.11',
  SOURCE_PORT=3306,
  SOURCE_USER='repl_pista',
  SOURCE_PASSWORD='<REPL_PASSWORD>',
  SOURCE_AUTO_POSITION=1,
  GET_SOURCE_PUBLIC_KEY=1;
START REPLICA;
SHOW REPLICA STATUS\G
```

### GTID 충돌 에러 시
```sql
-- 충돌 GTID 스킵
SET GTID_NEXT='<GTID_값>';
BEGIN; COMMIT;
SET GTID_NEXT='AUTOMATIC';
START REPLICA;
```
