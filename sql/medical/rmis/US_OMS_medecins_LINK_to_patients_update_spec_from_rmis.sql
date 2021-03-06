/*update medecins_info
set
PRVS_CL20=null
,D_SER=null
,PRVD_CL21=null
,D_PRIK=null
,D_PRIK_PROFILE=null
,STAV=null
*/
update medecins_info
set
PRVS_CL20=cl20.id
,D_SER=certificateDate
,PRVD_CL21=cl21.id
,D_PRIK=lpu_em.takeOnDate
,D_PRIK_PROFILE=lpu_sp.fromDate
,STAV=salaryRate
/*
SELECT 
lpu_sp.*
,'|' '|'
,cl20.name
,cl21.name
,'|' '|'
,lpu_p.*
,'|' '|'
,lpu_em.*
,'|' '|'
,medecins.nom
,medecins.kod1
*/
FROM
rmis_LPU_ServiceProfessional lpu_sp
left join rmis_LPU_Position lpu_p on lpu_sp.PositionUID=lpu_p.PositionUID
left join rmis_LPU_Employee lpu_em on lpu_sp.EmployeeUID=lpu_em.EmployeeUID
left join medecins on (
		(case when charindex('_',medecins.nom)>0 then 
			substring(medecins.nom,1,charindex('_',medecins.nom)-1)
			else medecins.nom end)=lpu_em.fam
		and lpu_em.im=substring(medecins.prenom,1,charindex(' ',medecins.prenom))
		and lpu_em.ot=substring(medecins.prenom
										,charindex(' ',medecins.prenom)+1
										,len(medecins.prenom)-charindex(' ',medecins.prenom))
		and medecins.kod1=((case when len(lpu_em.code)=2 then '0' else '' end)+lpu_em.code)
						
)
left join medecins_info on medecins.medecins_id=medecins_info.medecins_id
left outer join us_oms_cl2000 cl20 on medicalprofession=cl20.code
left outer join us_oms_cl2100 cl21 on specialitycode=cl21.code
where len(lpu_em.code)<4
--order by lpu_sp.EmployeeUID