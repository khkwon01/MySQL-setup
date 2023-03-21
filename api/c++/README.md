## Install g++ compiler
* yum install -y gcc-toolset-9-gcc gcc-toolset-9-gcc-c++

## Install c++ connector 
* rpm -ivh mysql-connector-c++-commercial-jdbc-8.0.31-1.1.el8.x86_64.rpm
* rpm -ivh mysql-connector-c++-commercial-devel-8.0.31-1.1.el8.x86_64.rpm
* rpm -ivh mysql-connector-c++-commercial-8.0.31-1.1.el8.x86_64.rpm

## How to compile a c++ code for legacy api
* g++ -std=c++11 -I /usr/include/mysql-cppconn-8 -L /usr/lib64 legacy_code.cc -lmysqlcppconn -o legacy_code

## How to compile a c++ code for mysqx api
* g++ -std=c++11 -I /usr/include/mysql-cppconn-8 -L /usr/lib64 mysqlx_code.cc -lmysqlcppconn8 -o mysqlx_code

## Refer document url
* https://dev.mysql.com/doc/dev/connector-cpp/8.0/
