-- admin 계정 (configureInstance시 생성)
-- CREATE USER 'admin'@'%' IDENTIFIED BY 'Ttatest1!'; 
-- GRANT ALL PRIVILEGES ON *.* TO admin@'%' WITH GRANT OPTION; 

-- mysqlsh tool 
-- 1/2/3번 서버별로..
dba.configureInstance('root:@127.0.0.1', {clusterAdmin: 'admin', clusterAdminPassword:'Ttatest1!', password:'Ttatest1!'})

-- cluster configuration check.
dba.checkInstanceConfiguration('admin@<1번ip>') 
dba.checkInstanceConfiguration('admin@<2번ip>') 
dba.checkInstanceConfiguration('admin@<3번ip>') 

-- 1번에서 admin으로 로그인
\c admin@<1번ip>

-- 이상이 없으면 cluster 생성 (1번)
var cluster = dba.createCluster('testCluster')
cluster.status()

-- 2번 추가하고 데이터 동기화
cluster.addInstance('admin@<2번ip>')
cluster.status()

-- 3번 추가하고 데이터 동기화
cluster.addInstance('admin@<3번ip>')
cluster.status()

-- cluster 관리용 admin
cluster.setupAdminAccount()

-- 3번 router 가동 (etc밑에 mysqlrouter config 생성, cluster.setupRouterAccount())
mysqlrouter --bootstrap admin@<3번ip> --user=mysqlrouter
systemctl start mysqlrouter

-- router 사용하여 접속 테스트
mysql -uadmin -p -h<3번ip> -P6446    -- write 전용
mysql -uadmin -p -h<3번ip> -P6447    -- read 전용

SELECT @@hostname, @@port;

-- primary 전환
cluster.setPrimaryInstance('tta-cluster01:3306');

-- cluster 중단시
router 중단 : systemctl stop mysqlrouter
cluster 중단 : 3번 -> 2번 -> 1번 (primary 제일 나중에)

-- cluster 시작시
1번 -> 2번 -> 3번
dba.rebootClusterFromCompleteOutage()

-- cluster 삭제
var cluster = dba.getCluster()
cluster.dissolve()


-- Global 옵션 조정
cluster.setOption('transactionSizeLimit', 900000000);
cluster.setOption('expelTimeout', 30);
cluster.setOption('consistency', 'BEFORE_ON_PRIMARY_FAILOVER');

-- help 보기
cluster.help('setOption')

-- router에서 instance 제외
-- cluster.setInstanceOption("admin@tta-cluster02:3306", "tag:_hidden", true);
-- cluster.setInstanceOption("admin@tta-cluster02:3306", "tag:_disconnect_existing_sessions_when_hidden", true);
-- cluster.setInstanceOption("admin@tta-cluster02:3306", "tag:_hidden", false);
-- cluster.setInstanceOption("admin@tta-cluster02:3306", "tag:_disconnect_existing_sessions_when_hidden", false);
-- cluster 상태 확인
mysqlsh admin@127.0.0.1 -- cluster status
