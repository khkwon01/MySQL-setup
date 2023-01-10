# tta 인증 설치
## 1. 설치 서버
| 구분 | OS | EA | 설치항목 |
|---|:---:|---:|---|
| `단일 서버` | Oracle Linux 8.6 or CentOS 8.0 | 1 | MySQL 8.0.31 Server, Shell |
| `이중화 서버` | Oracle Linux 8.6 or CentOS 8.0 | 3 | MySQL 8.0.31 Server, Shell, Router(3번서버) |
- 시스템 패키지 설치에 편이성을 위해 CentOS 보다는 Oracle linux 설치를 요청 (CentOS는 yum 대신  rpm를 올려서 설치해야함)
- CentOS일 경우 : yum install python39-libs, rpm -ivh mysql-shell..
- OS 방화벽은 DB 관련 포트를 다 오픈 하던가 아님 disable : systemctl stop firewall.service, systemctl dsiable firewall.service


## 2. MySQL 8.0.31 싱글 인스턴스 구성 (파일중 _single 항목)
### 1) 구성도
![image](https://user-images.githubusercontent.com/8789421/210689191-4d3fc35b-cff2-44da-801a-3aec88777556.png)

   - MySQL 시작 : /mysql/start_mysql.sh
   - MySQL 중단 : /mysql/stop_mysql.sh

### 2) Firewall 기능
#### A. 구성
   - 아래 명령어를 통해서 plugin 설치 
   - mysql -uadmin -p -h127.0.0.1 < linux_install_firewall.sql
   - (linux_install_firewall.sql가 firewall plugin 설치 스크립트)
#### B. 서비스 계정에서 아래 명령어를 사용하여 적용
   - call mysql.sp_set_firewall_mode('계정명', 'RECORDING');    <-- 서비스 SQL 리코딩(수집) 할때
   - call mysql.sp_set_firewall_mode('계정명', 'PROTECTING');   <-- 수집된 SQL로 이상한 SQL를 보호..
   - call mysql.sp_set_firewall_mode('계정명', 'DETECTING');    <-- 수집된 SQL로 이상한 SQL를 찾기만..
   - call mysql.sp_set_firewall_mode('계정명', 'OFF');    <-- 수집된 SQL로 이상한 SQL를 찾기만..
#### C. firewall 권한
   - FIREWALL_ADMIN, FIREWALL_EXEMPT
   
### 3) 패스워드, 마스킹, 감사, thread plugin
   - my.cnf 파일에 해당 plugin 내용 반영

### 4) TDE 암호화
#### A. 구성
   - my.cnf에서 encrypt 관련 옵션에 대해 #처리를 해제
   - mysql 시작시 --early-plugin-load 옵션을 사용하여 시작
#### B. file-based 암호화
   - create table ~~~ encryption = 'Y'



## 3. MySQL 8.0.31 Cluster 구성 (파일중 _cluster 항목)
### 1) 구성도
![image](https://user-images.githubusercontent.com/8789421/210688284-16182669-ae94-4183-9750-5583bdbcf17e.png)

   - 서비스포트 (Read/Write용) : 6446
   - 서비스포트 (Read용) : 6447


## 4. 기본 사용법
### 1) Cli 접속 
   - mysql -uroot -p -h 127.0.0.1
### 2) Jdbc driver 사용
   - mysql-connector-j-8.0.31.jar

## 5. MySQL8.0 매뉴얼
### 1) 웹사이트 : https://dev.mysql.com/doc/refman/8.0/en/
       
