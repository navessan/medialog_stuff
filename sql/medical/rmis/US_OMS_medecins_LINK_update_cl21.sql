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
case when medecins.specialisation like '%�����%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '%�����%')
when medecins.specialisation like '%��������%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '%��������%')
when medecins.specialisation like '%�������%' 
	and medecins.specialisation not like '�����%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '�����������-��������')
when medecins.specialisation like '����%�������%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '�����������-���������')
when medecins.specialisation like '����%���%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '�����������-�������')
when medecins.specialisation like '%���������%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '%���������%')
when medecins.specialisation like '%�������%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '%�������%')
when medecins.specialisation like '%�����������%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '�����������%')
when medecins.specialisation like '%�����������%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '�����������%')
when medecins.specialisation like '�������%���%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '����������%')
when medecins.specialisation like '%��%' or medecins.specialisation like '%�����%'then
	(select top 1 name from [US_OMS_CL2100]
	where name like '%�����%')
when medecins.specialisation like '%������%' or medecins.specialisation like '%���%'then
	(select top 1 name from [US_OMS_CL2100]
	where name like '%�������%')
when medecins.specialisation like '���%����%���%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '���%����%���%')
when medecins.specialisation like '����%����%���%' then
	(select top 1 name from [US_OMS_CL2100]
	where name like '����%����%���%')
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
