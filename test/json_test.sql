create database json;
use json;

create table json_table
(
    id bigint NOT NULL auto_increment,
    doc json,
    primary key(id)
);

select * from json_table;
