#!/bin/bash

mysqldump -usvcuser -p -h127.0.0.1 --single-transaction --database tde > /mysql/tde.sql
