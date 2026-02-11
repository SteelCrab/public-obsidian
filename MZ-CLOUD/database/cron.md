# CRON

# 1. 자동 백업 쉘 스크릡트 

## 📦 1.시간 동기화 `timedatectl`

```sql
timedatectl
```

### 타임 존 변경 

```sql
sudo timedatectl set-timezone Asia/Seoul
```


### 타임 존 확인 `timedatectl`

```sql
timedatectl
```


## 📦 2.백업 쉘스크립트 작성
> 편집 
```shell
vim auto_bakcup.sh
```
> 내용 
```shell

--------------------
#!/bin/sh
# ################# 변수 설정 #############
# 데이터베이스 연결 정보
DB_USER="<mysql_user_id>"   # DB 사용자 아이디
DB_PASSWORD="password"   # DB 사용자 비밀번호
DB_NAME="database_name"    # 사용자 아이디를 백업용 데이터베이스 이름으로 재 지정

# ===== 백업파일 정보 생성
# 백업파일 보관할 경로
BACKUP_DIR="$HOME/mysql_db_backup/$DB_USER"
# 디렉터리가 없을 경우 생성
if [ ! -d $BACKUP_DIR ]; then
        mkdir -p $BACKUP_DIR
fi
# 파일명으로 사용할 날짜 및 시간 만들기
DATE=$(date +"%Y%m%d%H%M%S")
# 백업파일 이름 지정 
BACKUP_FILE="$BACKUP_DIR/$DB_NAME.backup_$DATE.sql"
# ########### e:변수설정 ############

# mysqldump 명령어를 통한 백업
/usr/bin/mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE
gzip $BACKUP_FILE   # 저장공간 확보를 위한 압축

exit 0
```
> 실행 
```sql
~$ chmod +x auto_backup.sh
```


# 2. 쉘의 주기적인 수행 설정 ⭐️

# 3. 쉘의 주기적인 수행을 위한 설정


 