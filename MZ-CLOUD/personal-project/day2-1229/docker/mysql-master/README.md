# MySQL Master (Docker Compose)

> VM(172.100.100.11)에서 Docker Compose로 실행되는 MySQL Master (쓰기 전용)

## 디렉토리 구조

```
mysql-master/
├── docker-compose.yml
├── .env.example      # 환경변수 템플릿
├── config/
│   └── my.cnf        # MySQL 설정 (GTID 복제)
└── initdb.d/
    └── init.sql      # 초기화 스크립트
```

## 스토리지 구조

| 볼륨 | 컨테이너 경로 | 설명 |
|------|--------------|------|
| `./data` | `/var/lib/mysql` | **데이터 저장 (로컬)** |
| `./config/my.cnf` | `/etc/mysql/conf.d/my.cnf` | MySQL 설정 |
| `./initdb.d` | `/docker-entrypoint-initdb.d` | 초기화 SQL |
| `./logs` | `/var/log/mysql` | 로그 |

## 빠른 설정

```bash
# 1. 환경변수 파일 복사 및 수정
cp .env.example .env
vim .env

# 2. 데이터 디렉토리 생성 및 권한 설정
mkdir -p data logs
sudo chown -R 999:999 data logs

# 3. 컨테이너 실행
docker compose up -d
```

## 복제 계정 생성 (K8s Slave용)

```bash
docker exec -it mysql-master mysql -uroot -p
```

```sql
CREATE USER 'repl_pista'@'%' IDENTIFIED WITH mysql_native_password BY '<REPL_PASSWORD>';
GRANT REPLICATION SLAVE ON *.* TO 'repl_pista'@'%';
FLUSH PRIVILEGES;
```

## 상태 확인

```bash
# MySQL 접속
docker exec -it mysql-master mysql -uroot -p

# GTID 상태 확인
docker exec -it mysql-master mysql -uroot -p -e "SHOW MASTER STATUS\G"
```
