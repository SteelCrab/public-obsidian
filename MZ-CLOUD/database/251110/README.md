# Master-Slave 복제 구성

## 환경

| 서버 | IP | 역할 |
|------|---------|------|
| Master | 192.168.206.4 | 원본 DB |
| Slave | 192.168.206.5 | 복제 DB |

---

## Master 서버 (192.168.206.4)

### **1. 복제 사용자 생성**
```sql
CREATE USER 'pista'@'192.168.206.5' 
IDENTIFIED WITH mysql_native_password BY '<YOUR_PASSWORD>';

GRANT REPLICATION SLAVE ON *.* TO 'pista'@'192.168.206.5';

FLUSH PRIVILEGES;
```

### **2. 설정 편집**
```bash
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
```
외부 사용자 허용
```ini
#bind-address           = 127.0.0.1
#mysqlx-bind-address    = 127.0.0.1
```
 

```ini
server-id              = 1
```

### **3. 재시작**
```bash
sudo systemctl restart mysql
```

### Slave 서버 (192.168.206.5)

**접속 테스트**

```bash
mysql -h 192.168.206.4 -u pista -p
```

---


## Master 서버 (192.168.206.4)

### **1.접속** 

```shell

sudo mysql -u admin  -p
```

```sql
show master status\G
```

해당 내용 저장

```sql

*************************** 1. row ***************************
             File: binlog.000013
         Position: 157
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set:
1 row in set (0.00 sec)
```
슬레이브 확인

```sql 
 show grants for 'pista'@'192.168.206.5';
```


```sql
+-----------------------------------------------------------+
| Grants for pista@192.168.206.5                            |
+-----------------------------------------------------------+
| GRANT REPLICATION SLAVE ON *.* TO `pista`@`192.168.206.5` |
+-----------------------------------------------------------+
1 row in set (0.00 sec)
```

### **2.전체 백업**

```sql
mysqldump -u admin -p  --all-databases > ~/master_pista_all.sql
```


### **3.sql 파일 전송**

```sql
scp ./master_pista_all.sql pista@192.168.206.5:/home/pista/master_pista_all.sql
```

---

## SLAVE 서버 (192.168.206.5)

### 1. **DB 복원**

```shell
 mysql -u pista -p < master_pista_all.sql
```

### **2. 슬레이브 파일 편집**

```shell
 sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
```

```shell
 server-id              = 2
 read_only              = 1
```

### **3. 재시작**

```bash
sudo systemctl restart mysql
```



### **4. 복제 설정**

```shell
mysql -u root -p
```

```sql 
CHANGE MASTER TO
  MASTER_HOST='192.168.206.4',
  MASTER_PORT=3306,
  MASTER_USER='pista',
  MASTER_PASSWORD='<YOUR_PASSWORD>',
  MASTER_LOG_FILE='binlog.000013',
  MASTER_LOG_POS=157;

START SLAVE;
```

```sql
START SLAVE;
```

### **5. 슬레이브 상태 확인**

```ssql
SHOW SLAVE STATUS\G;
```

### **6. 상태 확인**

```sql
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
Master_Log_File: binlog.000013
Read_Master_Log_Pos: 157
```

**설정시 문제가 있을 경우**

```sql
STOP SLAVE;
RESET SLAVE ALL;
```
---

## 복제 동작 확인

### Master서버 (192.168.206.4)

테이블 생성 

```sql
USE testdb;
CREATE TABLE test_replication (
  id INT PRIMARY KEY,
  name VARCHAR(50)
);

INSERT INTO test_replication VALUES (1, 'test');
```

### SLAVE 서버 (192.168.206.5)

테이블 확인

```sql
USE pista;
SELECT * FROM test_replication;
```

