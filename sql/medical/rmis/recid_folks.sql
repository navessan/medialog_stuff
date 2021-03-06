
SELECT distinct
patients_id,
--dbo.hexadecimal (convert (varbinary, patients.patients_id)) hex,
--patients.recid,
patients.nom,
patients.prenom,
patients.patronyme,
--'|' '|',
nkart,z_folks_.recid,
--dbo.ConvertFromBase(z_folks_.recid,16),

fam,im,ot
--,*
  FROM [medialog7].[dbo].[z_folks_]
left outer join patients on (patients.nom=[z_folks_].fam
								and patients.prenom=[z_folks_].im
								and patients.patronyme=[z_folks_].ot
								and patients.ne_le=[z_folks_].dr
--		and dbo.hexadecimal (convert (varbinary, patients.patients_id))=z_folks_.recid
--and					patients.patients_id=dbo.ConvertFromBase(z_folks_.recid,16)
								)

group by 
patients_id,
patients.recid,
patients.nom,patients.prenom,patients.patronyme,
nkart,z_folks_.recid,fam,im,ot
having count(patients_id)>1

order by z_folks_.recid