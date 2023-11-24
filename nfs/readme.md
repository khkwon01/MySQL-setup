1. install nfs both of nfs server and client
yum install nfs-utils

2. start nfs
systemctl start nfs-utils.service

3. expose the shared file system to external vm
```
/workshop/linux 10.0.0.0/16(ro,sync,no_root_squash,no_all_squash)     
/workshop/databases 10.0.0.0/16(ro,sync,no_root_squash,no_all_squash)   
/workshop/support 10.0.0.0/16(ro,sync,no_root_squash,no_all_squash)   
/workshop/sshkeys 10.0.0.0/16(ro,sync,no_root_squash,no_all_squash)    
```

4. mount external vm from exporting system (source)
1) 
