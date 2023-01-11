-- admin에서 masking function 생성
CREATE FUNCTION gen_blocklist RETURNS STRING SONAME 'data_masking.so';
CREATE FUNCTION gen_dictionary RETURNS STRING SONAME 'data_masking.so';
CREATE FUNCTION gen_dictionary_drop RETURNS STRING SONAME 'data_masking.so';
CREATE FUNCTION gen_dictionary_load RETURNS STRING SONAME 'data_masking.so';
CREATE FUNCTION gen_range RETURNS INTEGER SONAME 'data_masking.so';
CREATE FUNCTION gen_rnd_email RETURNS STRING SONAME 'data_masking.so';
CREATE FUNCTION gen_rnd_pan RETURNS STRING SONAME 'data_masking.so';
CREATE FUNCTION gen_rnd_ssn RETURNS STRING SONAME 'data_masking.so';
CREATE FUNCTION gen_rnd_us_phone RETURNS STRING SONAME 'data_masking.so';
CREATE FUNCTION mask_inner RETURNS STRING SONAME 'data_masking.so';
CREATE FUNCTION mask_outer RETURNS STRING SONAME 'data_masking.so';
CREATE FUNCTION mask_pan RETURNS STRING SONAME 'data_masking.so';
CREATE FUNCTION mask_pan_relaxed RETURNS STRING SONAME 'data_masking.so';
CREATE FUNCTION mask_ssn RETURNS STRING SONAME 'data_masking.so';


-- 서비스 계정에서 
use tde;
select gen_range(1, 10);
select gen_rnd_us_phone();
select gen_rnd_email();

select mask_inner(col1, 1, 1) from tb_enc ;
select mask_outer(col1, 1, 1) from tb_enc ;
