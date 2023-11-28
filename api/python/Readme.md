## Install Python module
- yum install mysql-connector-python or
- pip install mysql-connector-python

## check python version
- python   
  > print(get_python_lib())

## sample code for using python mysql connector
```
""" connection example """"
import mysql.connector
from mysql.connector import errorcode
from mysql.connector.constants import ClientFlag
from datetime import date, datetime, timedelta

config = {
  'user': 'scott',
  'password': 'password',
  'host': '127.0.0.1',
  'database': 'employees',
  'raise_on_warnings': True,
  'buffered': True,
  'client_flags': [ClientFlag.SSL],    ## when it need to ssl
  'ssl_ca': '/opt/mysql/ssl/ca.pem',
  'ssl_cert': '/opt/mysql/ssl/client-cert.pem',
  'ssl_key': '/opt/mysql/ssl/client-key.pem'
}

try:
  cnx = mysql.connector.connect( **config )
except mysql.connector.Error as err:
  if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
    print("Something is wrong with your user name or password")
  elif err.errno == errorcode.ER_BAD_DB_ERROR:
    print("Database does not exist")
  else:
    print(err)
else:
  cnx.close()

""" create table """
cursor = cnx.cursor()
s_table = (
    "CREATE TABLE departments ("
    "  dept_no char(4) NOT NULL,"
    "  dept_name varchar(40) NOT NULL,"
    "  PRIMARY KEY (dept_no), UNIQUE KEY dept_name (dept_name)"
    ") ENGINE=InnoDB" )

try:
    print("Creating table {}: ".format(table_name), end='')          
    cursor.execute(table_description)
except mysql.connector.Error as err:
    if err.errno == errorcode.ER_TABLE_EXISTS_ERROR:
        print("already exists.")
    else:
        print(err.msg)
    else:
        print("OK")

""" insert data """
cursor = cnx.cursor()
add_employee = ("INSERT INTO employees "
               "(first_name, last_name, hire_date, gender, birth_date) "
               "VALUES (%s, %s, %s, %s, %s)")

data_employee = ('Geert', 'Vanderkelen', tomorrow, 'M', date(1977, 6, 14))

try:
    cursor.execute(add_salary, data_salary)
    emp_no = cursor.lastrowid
except mysql.connector.Error as err:

cnx.commit()

""" select data """
query = ("SELECT first_name, last_name, hire_date FROM employees "
         "WHERE hire_date BETWEEN %s AND %s")

hire_start = datetime.date(1999, 1, 1)
hire_end = datetime.date(1999, 12, 31)

try:
    cursor.execute(query, (hire_start, hire_end))
except mysql.connector.Error as err:

cnx.commit()

cursor.close()
cnx.close()


```
