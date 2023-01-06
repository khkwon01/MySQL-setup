create database json;
use json;

create table jsontable ( 
    id bigint NOT NULL AUTO_INCREMENT,
    doc JSON,
    primary key (id)
);

select * from jsontable;

insert into jsontable(doc) value('{"A": "hello", "b": "test", "c": {"hello": 1}}');
insert into jsontable(doc) value('{"b": "hello"}'),('{"c": {"hello": 1}}');

select * from jsontable;

SELECT json_extract (doc, "$.b") FROM jsontable;
SELECT doc->"$.b" FROM jsontable;
