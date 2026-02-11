#!/bin/bash

# 설정을 위해 Master의 Replication 계정 정보가 필요합니다
# 실행 전 환경변수 설정 필요:
#   export MASTER_PASSWORD=<복제계정 비밀번호>
#   export ROOT_PASSWORD=<Slave Root 비밀번호>
MASTER_HOST="mysql-master"
MASTER_USER="repl_pista"
MASTER_PASSWORD="${MASTER_PASSWORD:-<REPL_PASSWORD>}"
ROOT_PASSWORD="${ROOT_PASSWORD:-<ROOT_PASSWORD>}"

echo ">>> Configuring Replication on Slave (mysql-0)..."
kubectl exec -it mysql-0 -n gition -- mysql -u root -p${ROOT_PASSWORD} -e "
STOP SLAVE;
RESET SLAVE ALL;
CHANGE MASTER TO 
  MASTER_HOST='${MASTER_HOST}',
  MASTER_USER='${MASTER_USER}',
  MASTER_PASSWORD='${MASTER_PASSWORD}',
  MASTER_AUTO_POSITION=1;
START SLAVE;
SHOW SLAVE STATUS\G
"

echo ">>> Configuring Replication on Slave (mysql-1)..."
kubectl exec -it mysql-1 -n gition -- mysql -u root -p${ROOT_PASSWORD} -e "
STOP SLAVE;
RESET SLAVE ALL;
CHANGE MASTER TO 
  MASTER_HOST='${MASTER_HOST}',
  MASTER_USER='${MASTER_USER}',
  MASTER_PASSWORD='${MASTER_PASSWORD}',
  MASTER_AUTO_POSITION=1;
START SLAVE;
SHOW SLAVE STATUS\G
"
