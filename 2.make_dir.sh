#!/bin/bash

mkdir /mysql
mkdir -p /mysql/data
mkdir -p /mysql/temp
mkdir -p /mysql/log
mkdir -p /mysql/binlog
mkdir -p /mysql/etc

cp /root/tta-main/my.cnf_single /mysql/etc

chown -R mysql:mysql /mysql
