# MySQL EE 설치
## 1. 설치 서버
| 구분 | OS | EA | 설치항목 |
|---|:---:|---:|---|
| `단일 서버 (single)` | CentOS 8.0 | 1 | MySQL 8.0.31 Server, Shell, Monitor |
| `이중화 서버 (cluster)` | CentOS 8.0 | 3 | MySQL 8.0.31 Server, Shell, Router(3번서버) |
- 시스템 패키지 설치에 편이성을 위해 CentOS 보다는 Oracle linux 설치를 요청 (CentOS는 yum대신 rpm를 올려서 설치해야함)
- CentOS일 경우 : yum install python39-libs, rpm -ivh mysql-shell..
- OS 방화벽은 DB 관련 포트를 다 오픈 하던가 아님 disable : systemctl stop firewalld.service, systemctl disable firewalld.service
- 커널값 수정 : vm.swappiness 1
- 파일시스템은 xfs, 마운트 옵션은 noatime,nodiratime 포함 


## 2. MySQL 8.0.31 싱글 인스턴스 구성 (파일중 _single 항목)
### 1) 구성도
![image](https://user-images.githubusercontent.com/8789421/210689191-4d3fc35b-cff2-44da-801a-3aec88777556.png)

   - MySQL 시작 : /mysql/start_mysql.sh  => /home/mysql/start_mysql.sh
   - MySQL 중단 : /mysql/stop_mysql.sh  => /home/mysql/stop_mysql.sh 

### 2) Firewall 기능
#### A. 구성
   - 아래 명령어를 통해서 plugin 설치 
   - mysql -uroot -p -h127.0.0.1 mysql < linux_install_firewall.sql
   - (linux_install_firewall.sql가 firewall plugin 설치 스크립트)
#### B. 서비스 계정에서 아래 명령어를 사용하여 적용
   - call mysql.sp_set_firewall_mode('계정명', 'RECORDING');    <-- 서비스 SQL 리코딩(수집) 할때
   - call mysql.sp_set_firewall_mode('계정명', 'PROTECTING');   <-- 수집된 whitelist로 이상한 SQL를 보호..
   - call mysql.sp_set_firewall_mode('계정명', 'DETECTING');    <-- 수집된 whitelist로 이상한 SQL를 찾고 error log 기록
   - call mysql.sp_set_firewall_mode('계정명', 'OFF');    <-- firewall off
#### C. firewall 권한
   - FIREWALL_ADMIN, FIREWALL_EXEMPT
   
### 3) 패스워드, 마스킹, 감사, thread plugin
   - my.cnf 파일에 해당 plugin 내용 반영
   - audit script 수행 (audit 관련 함수 추가)
     - mysql -uroot -p -h127.0.0.1 mysql < audit_log_filter_linux_install.sql

### 4) TDE 암호화
#### A. 구성
   - mysql 설치가 완료되면 my.cnf에서 tde 옵션 uncomment 
   - mysql 시작시 early_plugin_load 옵션 포함하여 미리 load 되도록 조정
#### B. file-based 암호화
   - create table ~~~ encryption = 'Y'
   
### 5) Encryption 구성
#### A. 구성
   - mysql cli에서 아래 명령 수행
     - INSTALL COMPONENT "file://component_enterprise_encryption";
   - 기존(8.0.29)과 다르게 기본 암호화 function은 이미 설치 되어 있고, 위에 명령어 추가 관련 암호화 기능 설치

### 6) Monitoring 구성
#### A. 설치
   - chmod 700 mysqlmonitor-8.0.32.1445-linux-x86_64-installer.bin
   - sh mysqlmonitor-8.0.32.1445-linux-x86_64-installer.bin
     - 언어 : engnlish, system size : small, bundle db password : 다른것과 동일
   - 시작/중단/상태 체크 명령어
     - 상태체크 : /opt/mysql/enterprise/monitor/mysqlmonitorctl.sh status
     - 중단 : /opt/mysql/enterprise/monitor/mysqlmonitorctl.sh stop
     - 시작 : /opt/mysql/enterprise/monitor/mysqlmonitorctl.sh start
#### B. 접속 
   - https://single_ip:18443  (user : admin)

## 3. MySQL 8.0.31 Cluster 구성 (파일중 _cluster 항목)
### 1) 구성도
![image](https://user-images.githubusercontent.com/8789421/216266513-7ba0c569-4e77-49af-ac62-99952cf39763.png)

   - 서비스IP : <3번 서버 IP> 
   - 서비스포트 (Read/Write용) : 6446
   - 서비스포트 (Read용) : 6447
### 2) 사용시 주의사항 (아래는 요구사항임) 
   - Innodb 엔진만 지원 (table 구성시 참조)
   - Table primary key는 필수 
   - cluster 서버간 안정적인 네트웍
### 3) cluster 상태 확인
   - mysqlsh --uril admin@127.0.0.1
   - var cluster = dba.getCluster()
   - cluster.status()
### 4) PK 사용 강제화 (PK 사용하지 않을 경우 에러발생)
   - sql_require_primary_key 옵션 셋팅 (0 --> 1)
   - 혹시 테이블에 PK 생성이 안되어 있을 경우 내부적으로 생성 SET sql_generate_invisible_primary_key=ON;
### 5) Single Primary일 경우 성능 향상을 위해 아래 옵션 적용
   - set persist group_replication_paxos_single_leader = ON;    (default는 OFF)


## 4. 기본 사용법
### 1) Cli 접속 
   - mysql -uroot -p -h 127.0.0.1
### 2) Jdbc driver 사용
   - mysql-connector-j-8.0.31.jar

## 5. MySQL8.0 매뉴얼
### 1) 웹사이트 : https://dev.mysql.com/doc/refman/8.0/en/
       
## 6. 문제 생겼을 경우
### 1) show full processlist, show engine innodb status\G 수집
### 2) error log, 명령어 수행시 에러로그 수집
   
