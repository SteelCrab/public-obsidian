# USER SHELL 
시스템에 등록된 사용자 계정을 검색하는 쉘 스크립트

## user-1: 사용자 이름 받아 검색을 함

### 기능 
> 사용자 이름 입력 받음
``` sh
read -r -p "Enter username: " input
```
> * awk -F "`패턴문자`" '{print $`필드번호`}' -> n:`열번호`
> * users: 입력한 사용자 명을 포함하는 단어들이 저장됨
``` sh
users=`cat /etc/passwd | awk -F ":" '{print $1}' | grep $input`
```
> 반복하여 이름 검색함
``` sh
```
[users-1.sh](./users-1.sh)

### 실행 
``` bash
sh users.sh
```

## user-2: 사용자 이름을 받아 검색 후 없으면 사용자 추가
기존 [`user-1.sh`](./users-1.sh)유지

> input의 포함된 패턴 문자를 반복하여  있을 경우  카운터 `1` 발생
``` sh
chkcnt=0
for user in $users
do
    if [ "$user" == "$input" ]
    then
        chkcnt=`expr chknt + 1`
    fi
````


### 실행 
``` bash
sh users-2.sh
```

## user-3 
1. 사용자 추가 
``` sh
useradd [name]
```
2. 비밀번호 지정: `1111`
``` sh
useradd [name] -p 1111
```
3. 추가 설정 
* -/home/`directory` 생성
``` sh
useradd [name] -p 1111 -d /home/[name]
```
* -/home/`directory'/.* (.SSH 제외)
``` sh
useradd [name] -p 1111 -d /home/[name]
```
4. windows ssh login 

