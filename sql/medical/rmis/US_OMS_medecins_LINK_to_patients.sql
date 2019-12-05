
select
US_OMS_medecins_LINK.medecins_id
,US_OMS_medecins_LINK.patients_id
,medecins.nom
,medecins.prenom
,medecins.specialisation
,patients.nom
,patients.prenom
,patients.PATRONYME
,[ORGANIZACIQ_OBNOVLENNAQ]
,[ORGANIZACIQ_NOVOE]
,patients.*
from
 US_OMS_medecins_LINK
left join medecins on US_OMS_medecins_LINK.medecins_id=medecins.medecins_id
left join patients on (
		(case when charindex('_',medecins.nom)>0 then 
			substring(medecins.nom,1,charindex('_',medecins.nom)-1)
			else medecins.nom end)=patients.nom
		and patients.prenom=substring(medecins.prenom,1,charindex(' ',medecins.prenom))
		and patients.PATRONYME=substring(medecins.prenom
										,charindex(' ',medecins.prenom)+1
										,len(medecins.prenom)-charindex(' ',medecins.prenom))
		and ([ORGANIZACIQ_OBNOVLENNAQ]=118 or [ORGANIZACIQ_NOVOE]=86)
)
order by patients.nom