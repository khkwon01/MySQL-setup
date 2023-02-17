#!/bin/bash

mkdir -p /home/mysql
mkdir -p /home/mysql/data
mkdir -p /home/mysql/temp
mkdir -p /home/mysql/log
mkdir -p /home/mysql/binlog
mkdir -p /home/mysql/etc
mkdir -p /home/mysql/mysql-latest
mkdir -p /home/mysql/keyring

# single mysql
cp /root/tta-main/my.cnf_single /home/mysql/etc/my.cnf

# cluster mysql (when cluster mysql install, remove the comment and then change server id according to assigned id)
# cp /root/tta-main/my.cnf_cluster /home/mysql/etc/my.cnf

cp /root/tta-main/4.start_mysql.sh /home/mysql/start_mysql.sh
cp /root/tta-main/4.stop_mysql.sh /home/mysql/stop_mysql.sh
chmod 750 /home/mysql/start_mysql.sh
chmod 750 /home/mysql/stop_mysql.sh

chown -R mysql:mysql /mysql
echo "export PATH=/home/mysql/mysql-latest/bin:\$PATH" >> /etc/profile
echo "export PATH=/home/mysql/mysql-latest/bin:\$PATH" >> ~/.bashrc

source /etc/profile
. ~/.bashrc
