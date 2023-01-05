#!/bin/bash

mkdir /mysql
mkdir -p /mysql/data
mkdir -p /mysql/temp
mkdir -p /mysql/log
mkdir -p /mysql/binlog
mkdir -p /mysql/etc
mkdir -p /mysql/mysql-latest
mkdir -p /mysql/keyring

# single mysql
cp /root/tta-main/my.cnf_single /mysql/etc/my.cnf

# cluster mysql (when cluster mysql install, remove the comment and then change server id according to assigned id)
cp /root/tta-main/my.cnf_cluster /mysql/etc/my.cnf

cp /root/tta-main/4.start_mysql.sh /mysql/start_mysql.sh
cp /root/tta-main/4.stop_mysql.sh /mysql/stop_mysql.sh
chmod 750 /mysql/start_mysql.sh
chmod 750 /mysql/stop_mysql.sh

chown -R mysql:mysql /mysql
echo "export PATH=/mysql/mysql-latest/bin:\$PATH" >> /etc/profile
