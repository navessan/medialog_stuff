
truncate table us_oms_cl0700
insert into us_oms_cl0700
(s_regn,s_ogrn,s_name)
select s_regn,s_ogrn,s_name from cl0700
