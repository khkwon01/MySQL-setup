#/bin/bash

/mysql/mysql-latest/bin/mysqld --defaults-file=/mysql/etc/my.cnf --user=mysql &

# tde 암호화 사용할때
# /mysql/mysql-latest/bin/mysqld --defaults-file=/mysql/etc/my.cnf --early-plugin-load --user=mysql &
