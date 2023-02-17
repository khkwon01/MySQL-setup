#!/bin/bash

chown -R mysql:mysql /home/mysql/mysql-latest

/home/mysql/mysql-latest/bin/mysqld --defaults-file=/home/mysql/etc/my.cnf --initialize --user=mysql

echo "error check : " `grep -i err /home/mysql/log/err_log.log`
echo "root temp password : " `grep -i 'temporary password' /home/mysql/log/err_log.log | awk -F"host:" '{print $2}' `

# start mysql
/home/mysql/start_mysql.sh > /dev/null

# sleep 5 until mysql server startup..
sleep 5

# password를 Ttatest1! 로 설정
/home/mysql/mysql-latest/bin/mysql_secure_installation -h127.0.0.1
