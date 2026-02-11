# 데이터베이스 쉘 구현 


```shell
#!/bin/sh

DB_USER="admin"
DB_PASSWD="<YOUR_PASSWORD>"
DB_NAME="bookdb"

# date의 출력형식을 줄 때 +와 이후 큰 따옴포(")는 붙임
DATE=$(date +"%Y%m%d%H%M%S")
FILE_PATH="$HOME/mysql_backup/$DB_NAME/"
BACKUP_FILE="db_backup_$DATE.sql"
SAVE_FILE="$FILE_PATH$BACKUP_FILE"

if [ ! -d $FILE_PATH ]; then
        mkdir -p $FILE_PATH
fi
# 지정된 데이터베이스 백업
mysqldump -u $DB_USER -p$DB_PASSWD $DB_NAME > $SAVE_FILE


 
exit 0
```

## 반복 for
>  **Note**
>  for 변수= (data1 data2 data3...)
> for a in "a" "b" "c";do
>        echo $
> done
```shell
for name in "홍길동" "김유신" "아이유";do
        echo $name
done
```

## 배열
> **Note**
> 변수=("data1" "data2" "data3"...)
> ARR=(1, 2, 3)

```shell
DB_NAME=("db1" "db2" "db3")
# 배열 하나 출력 
echo $ARR[0]
# 배열 전체 출력
echo $ARR[@] 
```

## 응용 : 배열을 사용해 for 사용 
