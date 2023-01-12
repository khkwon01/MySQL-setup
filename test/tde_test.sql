create database tde;

create table tb_enc
(
  id int,
  col1 varchar(100),
  primary key(id)
) encryption = 'Y';
