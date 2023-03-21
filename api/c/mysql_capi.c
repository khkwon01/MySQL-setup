#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>


void finish_with_error(MYSQL *con)
{
  fprintf(stderr, "%s\n", mysql_error(con));
  mysql_close(con);
  exit(1);
}

int main(int argc, char **argv)
{
  MYSQL *mysql = mysql_init(NULL);
  char * host_name = "127.0.0.1";
  char * user_name = "root";
  char * password = "Ttatest1!";
  char * db_name = "tta";
  int port_num = 3306;
  char * socket_name = NULL;
  int status = 0;
  MYSQL_RES *result = NULL;
  MYSQL_ROW row = NULL;

  if (mysql == NULL)
  {
     printf("mysql_init() failed\n");
     exit(1);
  }


  if (mysql_real_connect (mysql, host_name, user_name, password,
    db_name, port_num, socket_name, CLIENT_MULTI_STATEMENTS) == NULL)
  {
     finish_with_error(mysql);
     exit(1);
  }

  /* execute multiple statements */
  status = mysql_query(mysql,
                       "DROP TABLE IF EXISTS test_table;\
                        CREATE TABLE test_table(id INT primary key, name varchar(10));\
                        INSERT INTO test_table VALUES(10, 'name10'),(20, 'name20'),(30,'name30');\
                        UPDATE test_table SET id=5 WHERE id=10;\
                        SELECT * FROM test_table;");
  if (status)
  {
    finish_with_error(mysql);
    exit(0);
  }

  /* process each statement result */
  do {
    /* did current statement return data? */
    result = mysql_store_result(mysql);
    if (result)
    {
      mysql_free_result(result);
    }
    else          /* no result set or error */
    {
      if (mysql_field_count(mysql) == 0)
      {
        printf("%lld rows affected\n",
              mysql_affected_rows(mysql));
      }
      else  /* some error occurred */
      {
        printf("Could not retrieve result set\n");
        break;
      }
    }
    /* more results? -1 = no, >0 = error, 0 = yes (keep looping) */
    if ((status = mysql_next_result(mysql)) > 0)
      finish_with_error(mysql);
  } while (status == 0);

  if (mysql_query(mysql, "SELECT * FROM test_table"))
  {
      finish_with_error(mysql);
  }

  result = mysql_store_result(mysql);

  if (result == NULL)
  {
      finish_with_error(mysql);
  }

  int num_fields = mysql_num_fields(result);

  while ((row = mysql_fetch_row(result)))
  {
      for(int i = 0; i < num_fields; i++)
      {
          printf("%s ", row[i] ? row[i] : "NULL");
      }
      printf("\n");
  }

  mysql_free_result(result);  
  
  mysql_close(mysql);


  exit(0);
}
