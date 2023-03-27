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

-- 
CALL mysql.sp_set_firewall_mode('fwtest@%', 'RESET');

-- group test
grant FIREWALL_ADMIN on *.* to root@'localhost';

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


-- firewall 삭제
DROP TABLE IF EXISTS mysql.firewall_group_allowlist;
DROP TABLE IF EXISTS mysql.firewall_groups;
DROP TABLE IF EXISTS mysql.firewall_membership;
DROP TABLE IF EXISTS mysql.firewall_users;
DROP TABLE IF EXISTS mysql.firewall_whitelist;
UNINSTALL PLUGIN MYSQL_FIREWALL;
UNINSTALL PLUGIN MYSQL_FIREWALL_USERS;
UNINSTALL PLUGIN MYSQL_FIREWALL_WHITELIST;
DROP FUNCTION IF EXISTS firewall_group_delist;
DROP FUNCTION IF EXISTS firewall_group_enlist;
DROP FUNCTION IF EXISTS mysql_firewall_flush_status;
DROP FUNCTION IF EXISTS normalize_statement;
DROP FUNCTION IF EXISTS read_firewall_group_allowlist;
DROP FUNCTION IF EXISTS read_firewall_groups;
DROP FUNCTION IF EXISTS read_firewall_users;
DROP FUNCTION IF EXISTS read_firewall_whitelist;
DROP FUNCTION IF EXISTS set_firewall_group_mode;
DROP FUNCTION IF EXISTS set_firewall_mode;
DROP PROCEDURE IF EXISTS mysql.sp_firewall_group_delist;
DROP PROCEDURE IF EXISTS mysql.sp_firewall_group_enlist;
DROP PROCEDURE IF EXISTS mysql.sp_reload_firewall_group_rules;
DROP PROCEDURE IF EXISTS mysql.sp_reload_firewall_rules;
DROP PROCEDURE IF EXISTS mysql.sp_set_firewall_group_mode;
DROP PROCEDURE IF EXISTS mysql.sp_set_firewall_group_mode_and_user;
DROP PROCEDURE IF EXISTS mysql.sp_set_firewall_mode;

위에 object 삭제후 사용중이던 object에 release를 위해 restart 수행
