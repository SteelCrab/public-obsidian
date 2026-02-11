[참고](https://www.notion.so/MySQL-29287ff2741980918545ff62e2364044?source=copy_link)
## MySQL 서비스 
### 📦 서비스 상태 확인
``` sql
sudo systemctl status mysql
```
![systemctl_mysql](./images/systemctl_mysql.png)
### 📦 sudo 접속
``` sql
sudo  mysql -u root -p 
```

### 📦 사용자 확인
``` sql
select user, host from mysql.user;
```
### 📦 사용자 추가
``` sql
CREATE USER 'admin'@'localhost' identified by '<YOUR_PASSWORD>';
```

![create_user](./images/create_user.png)

### 📦 사용자 확인
``` sql
SELECT USER, host FROM mysql.user;
```
![select_user](./images/users_table.png)

### 📦 즉시 적용
``` sql
flush privileges;
```
![cofig](./images/즉시_적용.png)

## MySQL Workbench 접속
``` sql

```
### 📦 
```sql

```
##

