#!/bin/bash

mysqldump -uroot -p -h127.0.0.1 --single-transaction --databases tde > /mysql/tde.sql
