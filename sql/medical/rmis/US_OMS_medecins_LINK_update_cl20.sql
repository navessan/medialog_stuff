
update medecins_info
set PRVS_CL20=CL2000_find.id
/*
select
medecins.nom
,medecins.prenom
,medecins.specialisation
,US_OMS_CL2000.name CL20_name

,CL2000_find.name CL20_find

,US_OMS_CL2100.code CL21_code
,US_OMS_CL2100.name CL21_name
,CL2000_find.id CL20_id
,PRVS_CL20
,PRVD_CL21
*/
from medecins
left join medecins_info on medecins.medecins_id=medecins_info.medecins_id
LEFT OUTER JOIN US_OMS_CL2000 ON US_OMS_CL2000.id=PRVS_CL20
LEFT OUTER JOIN US_OMS_CL2100 ON US_OMS_CL2100.id=PRVD_CL21
LEFT OUTER JOIN US_OMS_CL2000 CL2000_find ON CL2000_find.id=(
select top 1 id from US_OMS_CL2000 cl20
	inner join medecins_info info2 on (cl20.id=info2.PRVS_CL20 and info2.PRVD_CL21=medecins_info.PRVD_CL21)
)
where 
prvs_cl20 is null and 
prvd_cl21 is not null
--order by medecins.specialisation desc
