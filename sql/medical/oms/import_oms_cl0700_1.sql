/*
insert into us_oms_cl0700
(s_regn,s_ogrn,s_name)
select 
z.s_regn
,z.s_ogrn
,z.s_name
--*
from z_cl0700 z
left join us_oms_cl0700 us on z.s_regn=us.s_regn and z.s_ogrn=us.s_ogrn 
where us.s_ogrn is null
*/

/*
insert into oms_smo
(smo_region,smo_name,smo_ogrn)
*/
select 
us.s_regn
,us.s_name
,us.s_ogrn
--*
from us_oms_cl0700 us
left join oms_smo smo on us.s_regn=smo_region and us.s_ogrn=smo_ogrn
where smo_ogrn is null
order by us.s_regn


select
s_regn,s_ogrn,s_name
  FROM us_oms_cl0700 new
left join oms_smo on s_ogrn=smo_ogrn and s_regn=SMO_REGION
where new.s_regn not in('50', '77')
and oms_smo_id is null
order by new.s_regn