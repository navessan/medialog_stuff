update medecins_info
set PRVD_CL21=US_OMS_CL2100.id
/*
select
medecins.nom
,medecins.prenom
,medecins.specialisation
,US_OMS_CL2100.code CL21_code
,US_OMS_CL2100.name CL21_name

,PRVS_CL20
,PRVD_CL21
*/
from medecins
LEFT OUTER JOIN US_OMS_CL2100 ON US_OMS_CL2100.name=(
case when medecins.specialisation like '%сестр%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '%сестр%')
when medecins.specialisation like '%ортодонт%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '%ортодонт%')
when medecins.specialisation like '%ортопед%' 
	and medecins.specialisation not like 'травм%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like 'Стоматологи-ортопеды')
when medecins.specialisation like 'стом%терапев%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like 'Стоматологи-терапевты')
when medecins.specialisation like 'стом%хир%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like 'Стоматологи-хирурги')
when medecins.specialisation like '%гинеколог%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '%гинеколог%')
when medecins.specialisation like '%акушерк%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '%акушерк%')
when medecins.specialisation like '%офтальмолог%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like 'офтальмолог%')
when medecins.specialisation like '%рентгенолог%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like 'рентгенолог%')
when medecins.specialisation like 'рентген%лаб%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like 'рентгенлаб%')
when medecins.specialisation like '%фд%' or medecins.specialisation like '%функц%'then
	(select top 1 name from [US_OMS_CL2100]
	where name like '%функц%')
when medecins.specialisation like '%ультра%' or medecins.specialisation like '%узд%'then
	(select top 1 name from [US_OMS_CL2100]
	where name like '%ультраз%')
when medecins.specialisation like 'лаб%клин%лаб%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like 'лаб%клин%лаб%')
when medecins.specialisation like 'врач%клин%лаб%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like 'врач%клин%лаб%')
else
	(select top 1 name from [US_OMS_CL2100]
	where name like '%'
				+(case when charindex(' ',medecins.specialisation)>0 then
						substring(medecins.specialisation,1,charindex(' ',medecins.specialisation)-1)
					else medecins.specialisation end)
				+'%')
end
)
left join medecins_info on medecins.medecins_id=medecins_info.medecins_id
where prvd_cl21 is null
--order by medecins.specialisation desc
