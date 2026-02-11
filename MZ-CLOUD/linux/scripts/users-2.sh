#!/bin/sh

read -p "Enter username:" input

# awk -F "패턴문자" '{print $필드번호}' -> n:열번호
users=`cat /etc/passwd | awk -F ":" '{print $1}' | grep $input`

# 현재 입력된 계정명과 동일한 계정이 있을 경우 
chkcnt=0
for user in $users
do
    if [  "$user" == "$input"]
    then
        chkcnt=`expr $chknt + 1`
    fi
done

# chkcnt 를 통해 동일한 계정이 있는지 확인
if [ $chkcnt -eq 0 ]
then
    useradd "$input"
    echo "새로운 사용자 \"$input]\" 가 생성되었습니다."
else
    echo "사용자 \"$input\" 는 이미 존재하는 사용자입니다."
    
fi
exit 0