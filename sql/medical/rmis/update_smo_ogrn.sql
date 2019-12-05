update oms_smo
/*SELECT [cod_cmo]
      ,[cmo_c_t]
      ,[cmo_q]
      ,[q_ogrn]
,s_name, s_regn
,oms_smo.*
*/
set smo_ogrn=q_ogrn
  FROM [usreg].[dbo].[cmo_obl] 
left outer join [medialog7].[dbo].cl0700 on [cmo_obl].[q_ogrn]=cl0700.[s_ogrn] COLLATE DATABASE_DEFAULT
left outer join [medialog7].[dbo].oms_smo on smo_kod_org=[cmo_obl].cod_cmo COLLATE DATABASE_DEFAULT
where s_regn=77 and cmo_c_t=77
--order by q_ogrn