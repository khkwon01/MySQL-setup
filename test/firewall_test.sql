SHOW GLOBAL VARIABLES LIKE 'mysql_firewall_mode';
SHOW GLOBAL STATUS LIKE "firewall%";

CREATE USER 'fwtest'@'%' IDENTIFIED BY 'Ttatest1!';
grant all privileges on tde.* to 'fwtest'@'%';

CALL mysql.sp_set_firewall_mode('fwtest@%', 'RECORDING');
SELECT * FROM mysql.firewall_users;
SELECT * FROM mysql.firewall_whitelist;

-- fwtest 계정으로 sql 수행

SELECT * FROM information_schema.mysql_firewall_whitelist;

CALL mysql.sp_set_firewall_mode('fwtest@%', 'PROTECTING');

-- fwtest 계정으로 sql 수행

CALL mysql.sp_set_firewall_mode('fwtest@%', 'DETECTING');

-- fwtest 계정으로 sql 수행

CALL mysql.sp_set_firewall_mode('fwtest@%', 'OFF');



CALL mysql.sp_set_firewall_group_mode('fwgrp', 'RECORDING');
CALL mysql.sp_firewall_group_enlist('fwgrp', 'fwtest@%');

SELECT MODE FROM performance_schema.firewall_groups
       WHERE NAME = 'fwgrp';
       
SELECT * FROM performance_schema.firewall_membership
       WHERE GROUP_ID = 'fwgrp' ORDER BY MEMBER_ID;
       
SELECT RULE FROM performance_schema.firewall_group_allowlist
       WHERE NAME = 'fwgrp';
       
CALL mysql.sp_set_firewall_group_mode('fwgrp', 'PROTECTING');

CALL mysql.sp_firewall_group_delist('fwgrp', 'fwtest@%');
