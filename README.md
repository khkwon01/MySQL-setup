# tta

## 1. MySQL 8.0.31 싱글 인스턴스 구성
### 1) Firewall 기능
#### A. 구성
   - 아래 명령어를 통해서 plugin 설치 
   - mysql -uadmin -p -h127.0.0.1 < linux_install_firewall.sql
   - (linux_install_firewall.sql가 firewall plugin 설치 스크립트)
#### B. 서비스 계정에서 아래 명령어를 사용하여 적용
   - call mysql.sp_set_firewall_mode('계정명', 'RECORDING');    <-- 서비스 SQL 리코딩(수집) 할때
   - call mysql.sp_set_firewall_mode('계정명', 'PROTECTING');   <-- 수집된 SQL로 이상한 SQL를 보호..
   - call mysql.sp_set_firewall_mode('계정명', 'DETECTING');    <-- 수집된 SQL로 이상한 SQL를 찾기만..
   - call mysql.sp_set_firewall_mode('계정명', 'OFF');    <-- 수집된 SQL로 이상한 SQL를 찾기만..
   
### 2) 마스킹, 감사, thread plugin
   - my.cnf 파일에 해당 plugin 내용 반영
