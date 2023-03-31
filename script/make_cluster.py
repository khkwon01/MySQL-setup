import os;

print('==================================');
print('InnoDB Cluster Production set up');
print('==================================\n');
print('Setting up a MySQL InnoDB Cluster with 3 MySQL Server another instances,\n');

print('[Note that]');
print('cluster configuration account : clsconfadmin');
print('clsuter admin account : clsadmin');
print('cluster router account : clsrouter \n');


cln = shell.prompt('Please enter a cluster name: ', type ="text");
servers = shell.prompt('Please enter s server list over at least 3 servers (seperated by ,) : ', type="text");
dbPass = shell.prompt('Please enter a password for the MySQL root account: ', type ="password");


try:
       print('\nSet up configuration of Innodbcluster for each instances.');
       shell.connect('root@', dbPass);
       dba.configure_instance('root@127.0.0.1', password = dbPass);
except Exception as e:
       print('\nThe InnoDB Cluster could not be created.\n\nError.\n' + str(e));
