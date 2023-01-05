#!/bin/bash

mkdir /mysql
mkdir -p /mysql/data
mkdir -p /mysql/temp
mkdir -p /mysql/log
mkdir -p /mysql/binlog     

chown -R mysql:mysql /mysql
