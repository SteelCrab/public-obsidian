#!/bin/sh

read -p "Enter username:" input

# awk -F "패턴문자" '{print $필드번호}' -> n:열번호
users=`cat /etc/passwd | awk -F ":" '{print $1}' | grep $input`


for user in $users
do
    echo "계정명 : $user"
done

if [ "a" != "b" ]; then

    echo "존재하지 않는 계정입니다."
fi
exit 0