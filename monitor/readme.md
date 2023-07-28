

## 1. monitoring flow
![image](https://github.com/khkwon01/MySQL-setup/assets/8789421/442e0039-5ee8-4bc8-ac45-9788302217a9)

- inflexdb install
  ```
  wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.0.x86_64.rpm
  yum localinstall influxdb2-2.7.0.x86_64.rpm
  ```
  - inflexdb setup
    ```
    http://<<influxdb ip>>:8086/
    ```
- grafana install : yum install -y https://dl.grafana.com/enterprise/release/grafana-enterprise-10.0.3-1.x86_64.rpm
  - grafana setup
    ```
    http://<<grafana ip>>:3000/         # default user : admin (password : admin), after login in, you must change it.
    ```
- fluentbit install : curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
  - fluent configuration ( /etc/td-agent-bit/td-agent-bit.conf )
    ```
    [INPUT]
    name cpu
    tag  mysql_ee1.cpu

    # Read interval (sec) Default: 1
    interval_sec 5

    [INPUT]
    Name          disk
    Tag           mysql_ee1.disk
    Interval_Sec  5
    Interval_NSec 0


    [OUTPUT]
    Name          influxdb
    Match         *
    Host          10.0.10.42
    Port          8086
    HTTP_Token    qBsVNW-jNjhesvhTbiURHbKgGmkXiq4y8ORUQizy9-A-O5gzhVc3I34slZQILpc0r-QlvCaoIsgle5HpVgryjA==
    Database      db
    Bucket	  mysql
    Org           oracle
    Sequence_Tag  off
    ```
  

## 2. grafana flux query
```
from(bucket: "mysql")                                            // bucket name
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)        
  |> filter(fn: (r) => r["_measurement"] == "mysql_ee1.cpu")     // table name
  |> filter(fn: (r) => r["_field"] == "cpu_p")                   // column name
  |> yield()
```

## 3. monitoring screen
- influxdb
  ![image](https://github.com/khkwon01/MySQL-setup/assets/8789421/6b798a0c-db7c-49f0-9cec-784fdeb96cfd)
- grafana
  ![image](https://github.com/khkwon01/MySQL-setup/assets/8789421/64ca6293-5c35-4f78-b8ae-fd8255bd0f26)

