### 1. 8.4 신규 추가 또는 변경 사항
#### 1) InnoDB Default 값 변경 사항    
| InnoDB Name | MySQL 8.4 | MySQL 8.0 |
|---|---|---|
|innodb_buffer_pool_instances| 1 if innodb_buffer_pool_size < 1GB) else 1-64로 내부계산으로 설정 | 8 (or 1 if innodb_buffer_pool_size < 1GB) | 
|innodb_change_buffering| none | all |
|innodb_adaptive_hash_index| OFF | ON |
|innodb_flush_method| O_DIRECT | fsync |
|innodb_io_capacity| 10000 | 200 |
|innodb_log_buffer_size| 67108864 (64MB) | 16777216 (16MB) |
|innodb_numa_interleave| ON | OFF |
|innodb_use_fdatasync| ON | OFF |
- 위에 사항들은 주요 innodb 변수에 대해서만 기술하였고, 더 많은 변수에 대해 기본값들이 변경됨    

#### 2) Clone Plugin
- 데이터를 복제하기 위해 사용하는 Clone에 대한 버전 정책이 major와 minor만 동일하면 되는걸로 완화 되었음    
  (예, 8.4.0에서 8.4.14 버전 또는 그 반대 버전으로 데이터를 복제하는게 허용됨)

#### 3) MySQL native password 인증
- 8.4.0에서는 deprecated된 mysql_native_password가 더이상 default 지정값이 아님.    
  enable 하기 위해 시작시 mysql-native-password=ON으로 지정하거나 수행중인 MySQL에서 아래 명령어 수행    
  INSTALL PLUGIN mysql_native_password SONAME 'mysql_native_password_server.so'

#### 4) C API functions 재구현
- 8.3.0에서 제거 되었던 MySQL C API 함수를 8.4.0 복구하여 재구현함    
  (mysql_kill, mysql_real_query........, myqsl_stat_bind_param등)

#### 5) Group replication 변수 default 값 변경
- Group replication와 관련된 2개 주요 서버 변수의 값이 변경됨
  - group_replication_consistency : eventual --> before_on_primary_failover
  - group_replication_exit_state_action : read_only --> offline_mode

#### 6) FLUSH_PRIVILEGES privilege 권한 추가
- 신규 flush privileges 문장을 수행하기 위해 flush_privileges 권한 추가 (reload 권한 하위 호환을 유지)

#### 7) OPTIMIZE_LOCAL_TABLE privilege 권한 추가
- 신규 optimize_local_table 권한이 추가

#### 8) Automatic histogram updates 지원
- analyze table 수행할 때 auto update 옵션을 추가해서 table수행시 해당 테이블에 대해 histogram를 자동 수집   
  (default는 수집하지 않는 거면, auto 수집되는 걸 변경 할때는 옵션을 manual update로 지정하면 됨)

#### 9) MySQL Enterprise Firewall 기능 향상
- MySQL Firewall에서 제공하는 관련 stored procedures는 tranactional 방식으로 작동
- Firewall의 stored procedures는 불필요한 결합 SQL 수행 하지 않음 (예, delete + insert등)
- Firewall의 user-based stored procedures와 UDF는 deprecation(8.0.26) 알람 출력

#### 10) Keyring migration 
- keyring component에서 keyring plugin으로 마이그레이션 지원

### 2. 8.4 Deprecated 되는 변경 사항
- group_replication_allow_local_lower_version_join 시스템 변수는 8.4.0에서 deprecated 되어지고 관련경고 출력

### 3. 8.4 Removed 되는 변경 사항
- binlog_transaction_dependency_tracking : 8.0.35에서 deprecated 되었고, 8.4에서 삭제    
  (replication시 dependency 체크는 source mysqld에서 수행)
- group_replication_recovery_complete_at : 8.0.34에서 deprecated 되었고, 8.4에서 삭제
- avoid_temporal_upgrade, show_old_temporals : 5.6에서 deprecated 되었고, 8.4에서 삭제
- default_authentication_plugin : 8.0.27에서 deprecated 되었고, 8.4에서 삭제 (authentication_policy로 대체)
- replication SQL 문법 변경
  - replication시 source servers: master --> source 
    - ex, change master to --> change replication source to  (하위 옵션도 모두 source로 변경) 
    - ex, show master status --> show binary log status
    - ex, purge master logs --> purge binary logs
    - ex, show master logs --> show binary logs
  - replication시 replicas: slave --> replica
    - ex, start slave --> start replica  (하위 옵션도 master는 source로 변경)
    - ex, show slave status --> show replica status
    - ex, reset slave --> reset replica
- Plugins 삭제 또는 대체
  - authentication_fido, authentication_fido_client : authentication_webauthn로 대체
  - keyring_file : component_keyring_file로 대체
  - keyring_encrypted_file : component_keyring_encrypted_file로 대체
  - keyring_oci : component_keyring_oci로 대체
  - openssl_udf : component_enterprise_encryption로 대체
- Weak chiphers 지원
  - TLS v1.2 or TLS v1.3등, SHA2, 인증서, AES, AEAD 알고리즘등
- INFORMATION_SCHEMA.TABLESPACES: 8.0.22에서 deprecated 되었고, 8.4에서 삭제
- DROP TABLESPACE and ALTER TABLESPACE ENGINE절: 8.0에서 deprecated 되었고, 8.4에서 삭제
- LOW_PRIORITY with LOCK TABLES ... WRITE: 5.6에서 deprecated 되었고, 8.4에서 삭제
- AUTO_INCREMENT 생성시 floating-point 컬럼 사용: 8.0에서 deprecated 되었고, 8.4에서 삭제
- mysql_ssl_rsa_setup utility: 8.0.34에서 deprecated 되었고, 8.4에서 삭제 (openssl 사용가능시 startup시 자동생성)
- mysql_upgrade utility: 8.0.16에서 deprecated 되었고, 8.4에서 삭제
- mysqlpump utility: 8.0.34에서 deprecated 되었고, 8.4에서 삭제 (대신, mysqldump or mysqlshell 사용)
