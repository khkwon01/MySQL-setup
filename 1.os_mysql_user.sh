#!/bin/bash

groupadd mysql
useradd -r -g mysql -s /bin/false mysql

# install system package for centos
yum install -y ncurses-compat-libs
