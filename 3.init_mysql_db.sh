#!/bin/bash

chown -R mysql:mysql /mysql/mysql-latest

/mysql/mysql-latest/bin/mysqld --defaults-file=/mysql/etc/my.cnf --initialize --user=mysql

echo "error check : " `grep -i err /mysql/log/err_log.log`
echo "root temp password : " `grep -i 'temporary password' /mysql/log/err_log.log | awk -F"host:" '{print $2}' `

# start mysql
/mysql/start_mysql.sh > /dev/null

# sleep 5 until mysql server startup..
sleep 5

# password를 Ttatest1! 로 설정
/mysql/mysql-latest/bin/mysql_secure_installation -h127.0.0.1
