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

## 3. Sysbench 설치
### 1) curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
### 2) yum install sysbench

## 4. 성능 테스트
### 1) 테스트 환경
| 구분 | 세부 내용 | 비고 |
|---|:---:|:---|
| `DB 이름` | sysbench |  |
| `테이블 개수` | 10 | sbtestx |
| `테이블 사이즈` | 1천만건 | 총 1억 (10 * 천만건)  |
| `테이블 총용량` | 20GB | 10 * 2G  |


