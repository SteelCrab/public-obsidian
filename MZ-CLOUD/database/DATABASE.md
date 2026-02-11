# DATABASE
## Database 생성 
> 데이터베이스를 새로 만들 때 사용
### 형식

###  데이터베이스 목록 확인
``` sql
SHOW Databases;
```

### 데이터베이스 생성
![show_databases_1](./images/show_databases_1.png)
``` sql
CREATE DATABASE MSP05;
```
![create_database_msp05](./images/create_databases_msp05.png)
### 생성된 데이터베이스 목록 확인
``` sql
SHOW Databases;
```
![show_databases_2](./images/show_databases_2.png)

## 데이터베이스 삭제 
> 

### 기본 형식 
``` sql
DROP DATABASE [IF EXISTS] <databasename>;
```

### 데이터베이스 목록 확인
``` sql
SHOW DATABASES;
```
![show_databases_2](./images/show_databases_2.png)

### 데이터베이스 삭제
``` sql
DROP DATABASE msp05;
```
![drop_databases_1](./images/drop_database_msp05.png)


### 삭제된 데이터베이스 목록 확인 
``` sql
SHOW Databases;
```
![show_databases_3](./images/show_databases_3.png)
