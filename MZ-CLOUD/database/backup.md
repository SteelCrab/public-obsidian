# 백업

1. 백업 할 디렉터리 생성 
2. 백업 대상 선정
    * 데이터베이스
    * 테이블 
    * 모든 데이터베이스
3. 백업파일명
>  확장명 `.sql` 권장

```sql
database.table.sql
```

```sql
database.table.bak
```

## 백업할 폴더 생성

```shell
mkdir -p db-backups

cd db-backups && pwd db-backups
```

## 테이블 백업 `mysqldump`

```shell
mysqldump -u <user_name> -p <db_name> tjoin_member > <backup_name>
```

```shell
mysqldump -u admin -p bookdb tjoin_member > bookdb.tjoin_member.sql
```

## 데이터베이스 백업 `mysqldump`

```shell
mysqldump -u <user_name> -p <db_name>  > <db_name>.sql
```

> 옵선`--no-create-info` : 생성 정보를 포함 안함

```shell
mysqldump -u <user> -p <db_name> --no-create-info   > <db_name>.sql
```
예시

```shell
mysqldump -u admin -p bookdb --no-create-info > nocreate_bookdb.sql
```

> 옵션 `--complete-insert` : 컬럼명 추가해서 백업  (추천) 

```sql
mysqldump -u <user> -p <db_name> --no-create-info --complete-insert  > <db_name>.sql
```

```sql
mysqldump -u admin -p bookdb --no-create-info --complete-insert  > column_bookdb.sql
```
> 옵션 `--databases` : 데이터베이스들 백업 

```sql
mysqldump -u <user> -p --databases <db_name_1> <db_name_2>...  > <db_name>.sql
```

예시 1 : 단일 db 백업

```sql
mysqldump -u admin -p --databases bookdb > use_boodb.sql
```

예시 2 : 여러 db 백업 

```sql
mysqldump -u admin -p --databases bookdb > use_boodb.sql
```

## 데이터베이스들 백업 `mysqldump`

* 권장하지 않은 기능

* 하나회사에서 서버를 하나 운영시 사용 


* 가급적이면 데이베이스 단위별로 백업 하는게 좋음 

```sql
mysqldump -u admin -p ---all-databases > <database_name>.sql
```

예시 1

```sql
 mysqldump -u admin -p --all-databases > all.db.sql
```
# 복구

## 테이블 복구 `mysql`

```sql
 mysql -u admin -p <db_name> < <db_name>.sql 
```

## 데이터베이스 복구 `mysql`

```sql
 mysql -u admin -p  < <db_name>.sql 
```

예시

```sql
 mysql -u admin -p  < ./use_bookdb.sql 
```

예시 : nocreate 복구

```sql
mysql -u admin -p <db_name> < nocreate_bookdb.sql
```

### db 생성

예시 

```sql
mysqldump -u admin -p create testdb
```

### db 제거 

예시

```sql
mysqldump -u admin -p drop testdb
```

### 

```sql
mysql -u admin -p create testdb
```

