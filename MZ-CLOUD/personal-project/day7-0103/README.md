# Day 7 - MySQL Replication (Master-Slave)

## 📋 목차

| 섹션 | 설명 |
|------|------|
| [📌 개요](#-개요) | 아키텍처 및 목표 |
| [⚙️ Master 설정](#️-master-설정) | 복제 계정 확인 |
| [🔄 Slave 설정](#-slave-설정) | 복제 시작 |
| [✅ 확인](#-확인) | 복제 상태 모니터링 |
| [🔧 트러블슈팅](#-트러블슈팅) | 문제 해결 |

---

## 📌 개요

MySQL Master-Slave 복제를 구성하여 Read/Write 분리를 구현합니다.

| 역할 | 위치 | 용도 |
|------|------|------|
| **Master** | VM (172.100.100.11) | 쓰기 (Write) |
| **Slave** | K8s Pod (mysql-0, mysql-1) | 읽기 (Read) |

- `MASTER_AUTO_POSITION=1`: GTID 기반 복제를 사용하여 Slave가 자동으로 Master의 로그 위치를 찾음

---

## ⚙️ Master 설정

Master에 복제용 계정(`repl_pista`)이 있는지 확인합니다.

```bash
docker exec -it mysql-master mysql -u root -p -e "SELECT user FROM mysql.user WHERE user='repl_pista';"
```

---

## 🔄 Slave 설정

K8s Master(k8s-m)에서 실행합니다.

```bash
kubectl exec -it mysql-0 -n gition -- mysql -u root -p<ROOT_PASSWORD> -e "
STOP SLAVE;
RESET SLAVE ALL;
CHANGE MASTER TO 
  MASTER_HOST='mysql-master',
  MASTER_USER='repl_pista',
  MASTER_PASSWORD='<REPL_PASSWORD>',
  MASTER_AUTO_POSITION=1;
START SLAVE;
"
```

`mysql-1`도 동일하게 실행합니다.

---

## ✅ 확인

복제 상태를 확인합니다.

```bash
kubectl exec -it mysql-0 -n gition -- mysql -u root -p<ROOT_PASSWORD> -e "SHOW SLAVE STATUS\G" | grep -E "Slave_IO_Running|Slave_SQL_Running"
```

**정상 출력:**
```
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
```

---

## 🔧 트러블슈팅

| 문제 | 원인 | 해결 |
|------|------|------|
| `Slave_IO_Running: No` | Master 접속 실패 | `mysql-master` 서비스 및 Endpoints 확인 |
| `Slave_SQL_Running: No` | SQL 오류 | `Last_SQL_Error` 확인 |
| `server-id` 충돌 | 동일 ID 사용 | `initContainer` 확인 |

---

## 📚 참고

- [Day 1 - 인프라 구축](../day1-1224/install-3tier/README.md)
- [Day 6 - MySQL Primary 접속](../day6-0102/README.md)
