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
cp /root/MySQL-setup-main/my.cnf_single_new /home/mysql/etc/my.cnf

# cluster mysql (when cluster mysql install, remove the comment and then change server id according to assigned id)
# cp /root/MySQL-setup-main/my.cnf_cluster_new /home/mysql/etc/my.cnf

cp /root/MySQL-setup-main/4.start_mysql.sh /home/mysql/start_mysql.sh
cp /root/MySQL-setup-main/4.stop_mysql.sh /home/mysql/stop_mysql.sh
chmod 750 /home/mysql/start_mysql.sh
chmod 750 /home/mysql/stop_mysql.sh

chown -R mysql:mysql /home/mysql
echo "export PATH=/home/mysql/mysql-latest/bin:\$PATH" >> /etc/profile
echo "export PATH=/home/mysql/mysql-latest/bin:\$PATH" >> ~/.bashrc

source /etc/profile
. ~/.bashrc
