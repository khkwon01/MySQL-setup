import os;

print('==================================');
print('InnoDB Cluster Production set up');
print('==================================\n');
print('Setting up a MySQL InnoDB Cluster with 3 MySQL Server another instances,\n');

print('[Note that]');
print('you must create the following account');
print("create user root@'%' identified by '<yourpassword>';\ngrant all privileges on *.* to root@'%' with grant option;");
print('cluster configuration account : clsconfadmin');
print('clsuter admin account : clsadmin');
print('cluster router account : clsrouter \n');


cln = shell.prompt('Please enter a cluster name: ', type ="text");
servers = shell.prompt('Please enter s server list over at least 3 servers (seperated by ,) : ', type="text");
dbPass = shell.prompt('Please enter a password for the MySQL root account: ', type ="password");
expelTm = 30
failCs = "BEFORE_ON_PRIMARY_FAILOVER"
n_index = 1
o_cls = None

try:
       print('\nSet up configuration of Innodbcluster for each instances.');
       for s_server in servers.strip().split(','):
          print("=================================");
          print(s_server + " try to setup cluster.");
          shell.connect('root@'+s_server, dbPass);
          shell.options.set_persist('history.autoSave', 'true');
          dba.configure_instance('root@'+s_server, password=dbPass, clusterAdmin = 'clsconfadmin', clusterAdminPassword = dbPass);
          shell.connect('clsconfadmin@'+s_server, dbPass);

          if n_index == 1 : 
             o_cls = dba.create_cluster(cln, failoverConsistency = failCs, expelTimeout = expelTm); 
             o_cls.setup_admin_account('clsadmin', password=dbPass);
             o_cls.setup_router_account('clsrouter', password=dbPass);
          else :
             if o_cls != None:
                o_cls.add_instance('clsconfadmin@'+s_server)

          n_index = n_index + 1

       print('\nfinished to setup innodb cluster');
          
except Exception as e:
       print('\nThe InnoDB Cluster could not be created.\n\nError.\n' + str(e));
