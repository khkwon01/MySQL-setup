-- admin 계정
CREATE USER 'admin'@'%' IDENTIFIED BY 'Ttatest1!';
GRANT ALL PRIVILEGES ON *.* TO admin@'%' WITH GRANT OPTION;

-- mysqlsh tool 
-- 1/2/3번 서버
dba.configureInstance('root:@127.0.0.1', {clusterAdmin: 'admin', clusterAdminPassword:'Ttatest1!', password:'Ttatest1!'})

-- cluster configuration check.
dba.checkInstanceConfiguration('admin@<1번ip>') 
dba.checkInstanceConfiguration('admin@<2번ip>') 
dba.checkInstanceConfiguration('admin@<3번ip>') 

-- 이상이 없으면 cluster 생성 (1번)
var cluster = dba.createCluster('testCluster')
cluster.status()

-- 2번 추가하고 데이터 동기화
cluster.addInstance('admin@<2번ip>')
cluster.status()

-- 3번 추가하고 데이터 동기화
cluster.addInstance('admin@<3번ip>')
cluster.status()

-- 3번 router 가동 (etc밑에 mysqlrouter config 생성)
mysqlrouter --bootstrap admin@admin@<3번ip> --user=mysqlrouter
systemctl start mysqlrouter

-- router 사용하여 접속 테스트
mysql -uadmin -p -h<3번ip> -P6446    -- write 전용
mysql -uadmin -p -h<3번ip> -P6447    -- read 전용

SELECT @@hostname, @@port;

-- primary 전환
cluster.setPrimaryInstance('tta-cluster01');

-- cluster 중단시
router 중단 : systemctl stop mysqlrouter
cluster 중단 : 3번 -> 2번 -> 1번 (primary 제일 나중에)

-- cluster 시작시
1번 -> 2번 -> 3번
dba.rebootClusterFromCompleteOutage()

-- cluster 삭제
var cluster = dba.getCluster()
cluster.dissolve()


-- 옵션 조정
cluster.setOption('transactionSizeLimit', 900000000);

-- help 보기
cluster.help('setOption')