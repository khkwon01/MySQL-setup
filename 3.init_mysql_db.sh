#!/bin/bash

/mysql/mysql-latest/bin/mysqld --defaults-file=/mysql/etc/my.cnf --initialize --user=mysql

echo "error check : " `grep -i err /mysql/log/err_log.log`
echo "root temp password : " `grep -i 'temporary password' /mysql/log/err_log.log | awk -F"host:" '{print $2}' `
