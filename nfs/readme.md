1. install nfs both of nfs server and client
```
yum install nfs-utils
systemctl enable nfs-server
```

2. expose the shared file system to external VM
  - register nfs filesystem in /etc/exports for exposing external
  ```
  /workshop/linux 10.0.0.0/16(ro,sync,no_root_squash,no_all_squash)     
  /workshop/databases 10.0.0.0/16(ro,sync,no_root_squash,no_all_squash)   
  /workshop/support 10.0.0.0/16(ro,sync,no_root_squash,no_all_squash)   
  /workshop/sshkeys 10.0.0.0/16(ro,sync,no_root_squash,no_all_squash)
  /workshop/test 10.0.0.0/16(rw,sync,no_root_squash,no_all_squash)
  ```
  - start nfs server
  ```
  systemctl start nfs-server
  exportfs -a
  ```


3. mount external vm from exporting system (source)
  - register nfs in /etc/fstab
  ```
  10.10.10.10:/workshop/test /workshop/test nfs defaults,nofail,nosuid,resvport 0 0
  ```
  - mount nfs filesystem
  ```
  mount /workshop/test
  ```
