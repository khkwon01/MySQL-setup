#!/bin/bash

program=$1

gcc -c `mysql_config --cflags` ${program}.c
gcc -o $program ${program}.o `mysql_config --libs`
