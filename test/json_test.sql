create database json;
use json;

create table json_table ( id bigint NOT NULL AUTO_INCREMENT,
    doc JSON,
    primary key (id)
);

select * from json_table;

insert into json_table(doc) value('{"A": "hello", "b": "test", "c": {"hello": 1}}');
insert into json_table(doc) value('{"b": "hello"}'),('{"c":"c": {"hello": 1}}');
