
# MySQL8.0 Community와 MySQL8.0 EE 비교

## 1. 사용 환경
### 1) OS : Rocky 8.7
### 2) HW : Oracle VM.Standard.E4.Flex (AMD cpu)
### 3) 기본 패키지 설치
       - yum install wget
       - yum install unzip
       - yum install ncurses-compat-libs
       - yum install sysstat

## 2. MySQL 설치
### 1) Community 설치
       - 다운로드 : wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.34-linux-glibc2.12-x86_64.tar
### 2) Enterprise 설치
       - edelivery.oracle.com 에서 다운로드 (계정 필요)
### 3) Variables 값 비교 
       - 아래 서버 환경에 영향 받는 변수 및 라이센스 관련된 부분을 제외하고는 모든 파라미터 값 동일 (파일중 xlsx 참조)
       ```
       build_id                                                 	 252698fe27ba725a3b3a36500f1d3509550b489c    
       hostname                                                 	 mysql8-0-ee-885358                          
       license                                                  	 Commercial                                  
       relay_log                                                	 mysql8-0-ee-885358-relay-bin        
       relay_log_basename                                       	 /home/mysql/data/mysql8-0-ee-885358-relay-bin         
       relay_log_index                                          	 /home/mysql/data/mysql8-0-ee-885358-relay-bin.index   
       server_id                                                	 2                                                     
       server_uuid                                              	 66a4ea97-2b5c-11ee-a533-0200170176bd                  
       version                                                  	 8.0.34-commercial               
       version_comment                                          	 MySQL Enterprise Server - Commercial    
       ```

## 3. Sysbench 설치
### 1) curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
### 2) yum install sysbench

## 4. 성능 테스트
### 1) 테스트 환경
| 구분 | 세부 내용 | 비고 |
|---|:---|:---|
| `DB 이름` | sysbench |  |
| `테이블 개수` | 10 | sbtestx |
| `테이블 사이즈` | 1천만건 | 총 1억 (10 * 천만건)  |
| `테이블 총용량` | 20GB | 10 * 2G  |     
### 2) sysbench 테스트
  - 데이터 생성
    ```
    sysbench --db-driver=mysql --time=50 --threads=10 --report-interval=20 --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=systest --mysql-password="" --mysql-db=sysbench --tables=10 --table_size=10000000 oltp_read_write prepare
    ```
  - sql read/write 테스트 수행 (read 70%, write 30%)
    ```
    sysbench --db-driver=mysql --time=100 --threads=50 --report-interval=20 --mysql-host=127.0.0.1 --mysql-port=3306 --mysql-user=systest --mysql-password="Welcome#1" --mysql-db=sysbench --tables=10 --table_size=10000000 oltp_read_write run
    ```
   - 테스트 결과    
     
     - Community 
       | 구분 | tps (sec) | cpu | 비고 |
       |---|:---|:---|:---|
       | `thread 50`  | 262.62 | 82.77 (user: 19.29, iowait: 53.94) |  |
       | `thread 100` | 358.71 | 75.33 (user: 24.11, iowait: 38.37) |  |
       | `thread 200` | 430.31 | 72.56 (user: 30.58, iowait: 11.47) | 80초부터 tps가 1/5로 떨어짐  |
       | `thread 300` | 524.11 | 72.36 (user: 37.17, iowait: 17.52) | 80초부터 tps가 1/5로 떨어짐  |
       | `thread 400` | 639.06 | 76.26 (user: 45.16, iowait: 23.74) | 80초부터 tps가 1/5로 떨어짐  |      

       동시 사용(thread) 세션을 200개 이상으로 설정하여 테스트시 아래와 같이 cpu 사용률이 90%이상을 도달한 후 성능이 떨어짐
       ![image](https://github.com/khkwon01/MySQL-setup/assets/8789421/1cc5bcfc-7340-4f3d-ae13-34113fec1089)     

     - Enterprise 
       | 구분 | tps (sec) | cpu | 비고 |
       |---|:---|:---|:---|
       | `thread 50`  | 320.01 | 85.58 (user: 22.39, iowait: 52.06) |  |
       | `thread 100` | 455.11 | 61.29 (user: 30.39, iowait: 15.78) |  |
       | `thread 200` | 502.53 | 72.56 (user: 33.68, iowait: 13.93) | 80초부터 tps가 1/4로 떨어짐  |
       | `thread 300` | 835.60 | 85.89 (user: 55.35, iowait: 5.57)  | 80초부터 tps가 1/3로 떨어짐  |
       | `thread 400` | 942.80 | 94.42 (user: 64.61, iowait: 5.58)  | 80초부터 tps가 1/3로 떨어짐  |               

