1. install nfs both of nfs server and client
```
yum install nfs-utils
systemctl enable nfs-server
```
2. start nfs
```
systemctl start nfs-utils.service
```
3. expose the shared file system to external VM
a) register nfs filesystem in /etc/exports for exposing external
```
/workshop/linux 10.0.0.0/16(ro,sync,no_root_squash,no_all_squash)     
/workshop/databases 10.0.0.0/16(ro,sync,no_root_squash,no_all_squash)   
/workshop/support 10.0.0.0/16(ro,sync,no_root_squash,no_all_squash)   
/workshop/sshkeys 10.0.0.0/16(ro,sync,no_root_squash,no_all_squash)
/workshop/test 10.0.0.0/16(rw,sync,no_root_squash,no_all_squash)
```
b) start nfs server
```
systemctl start nfs-server
exportfs -a
```


4. mount external vm from exporting system (source)
a) register nfs in /etc/fstab
```
10.10.10.10:/workshop/test /workshop/test nfs defaults,nofail,nosuid,resvport 0 0
```
b) mount nfs filesystem
```
mount /workshop/test
```
