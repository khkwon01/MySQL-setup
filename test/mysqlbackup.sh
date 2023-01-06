-- root 계정으로 하거나, 백업 계정을 만들 경우 backup_user.sh로 생성


-- tde 파일이 없을 경우 백업
mysqlbackup --host=127.0.0.1 --protocol=tcp --user=root --password --backup-dir=/mysql/backup backup-and-apply-log


-- tde 파일이 있을 경우 백업
mysqlbackup --host=127.0.0.1 --protocol=tcp --user=root --password --backup-dir=/mysql/backup --encrypt-password backup-and-apply-log


-- 복구시 
mysqlbackup --defaults-file=/mysql/etc/my.cnf --backup-dir=/mysql/backup --datadir=/mysql/data --log-bin=/mysql/binlog/binlog copy-back
