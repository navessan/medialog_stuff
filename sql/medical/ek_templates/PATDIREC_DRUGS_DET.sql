/*
select MAX(patdirec_id)
from PATDIREC

*/

declare @offset_PATDIREC_ID int
		,@offset_PR_DRUGS_ID int

select @offset_PATDIREC_ID=20000
	  ,@offset_PR_DRUGS_ID=1000


/*
insert into PATDIREC_DRUGS
([PATDIREC_DRUGS_ID]
      ,[PATDIREC_ID]
      ,[DRUG_DESCR]
      ,[OWN_DRUGS]
      ,[TYPE_RECEPTION]
      ,[FOODLINK]
      ,[IS_MIXT]
      ,[DM_MEASURE_ID]
      ,[ON_DEMAND]
      ,[IS_COMPLEX]
      ,[INTAKES_PER_DAY]
      ,[DOSE]
      ,[INTAKES_STR]
      ,[USE_WORKING_DAYS]
      ,[OLD_VERSION])
*/
insert into PATDIREC_DRUGS_DET
([PATDIREC_DRUGS_DET_ID]
      ,[PATDIREC_DRUGS_ID]
      ,[PR_DRUGS_ID]
      ,[DM_MEASURE_ID]
      ,[DOSE])

select 
/*
@offset_PATDIREC_ID+ROW_NUMBER()over (order by PATDIREC.[PATDIREC_ID]) as id
--,PATDIREC.PL_EXAM_ID as old_pl_exam_id
--,pl_exam.NAME,
--new.NAME
--,PATDIREC.[PATDIREC_ID]
      ,(case when len(new.CODE_AK)>0 then new.PL_EXAM_ID else 1516 end) as [PL_EXAM_ID]
      ,[QUANTITY]
      ,[QUANTITY_DONE]
      ,PATDIREC.[DESCRIPTION]
      ,[COMMENTAIRE]
      ,[CANCELLED]
      ,[STANDARTED]
      ,[CITO]
      ,[DIR_STATE]
      ,[BEGIN_DATE_TIME]
      ,[END_DATE_TIME]
      ,[TEMPLATE_XML]
      ,[QUANTITY_CANCEL]
      ,PATDIREC.[PR_TEMPLATE_SCHEMES_ID]
      ,[MANIPULATIVE]
      ,[SUSPENDED]
      ,[NEED_OPEN_EDITOR]
      ,[KEEP_INTAKE_TIME]
      ,[THERAPY_CHECK_STATE]
      ,[PATDIREC_KIND]
,'|' '|'

ROW_NUMBER()over (order by PATDIREC.[PATDIREC_ID]) as [PATDIREC_DRUGS.PATDIREC_DRUGS_ID]
      ,@offset_PATDIREC_ID+ROW_NUMBER()over (order by PATDIREC.[PATDIREC_ID]) as [PATDIREC_DRUGS.PATDIREC_ID]
      ,[DRUG_DESCR]
      ,[OWN_DRUGS]
      ,[TYPE_RECEPTION]
      ,[FOODLINK]
      ,[IS_MIXT]
      ,PATDIREC_DRUGS.[DM_MEASURE_ID]
      ,[ON_DEMAND]
      ,[IS_COMPLEX]
      ,[INTAKES_PER_DAY]
      ,PATDIREC_DRUGS.[DOSE]
      ,[INTAKES_STR]
      ,[USE_WORKING_DAYS]
      ,[OLD_VERSION]
     
,'|' '|',
*/
	  ROW_NUMBER()over (order by PATDIREC.[PATDIREC_ID]) as [PATDIREC_DRUGS_DET.PATDIREC_DRUGS_DET_ID]
      ,ROW_NUMBER()over (order by PATDIREC.[PATDIREC_ID]) as [PATDIREC_DRUGS_DET.PATDIREC_DRUGS_ID]
      ,[PATDIREC_DRUGS_DET].[PR_DRUGS_ID]+@offset_PR_DRUGS_ID as [PR_DRUGS_ID]
      ,[PATDIREC_DRUGS_DET].[DM_MEASURE_ID]
      ,[PATDIREC_DRUGS_DET].[DOSE]
      
from [10.255.69.10].[med_euroonco_new].[dbo].PATDIREC
join [10.255.69.10].[med_euroonco_new].[dbo].[PR_TEMPLATE_SCHEMES] on PATDIREC.PR_TEMPLATE_SCHEMES_ID=[PR_TEMPLATE_SCHEMES].PR_TEMPLATE_SCHEMES_ID
join [10.255.69.10].[med_euroonco_new].[dbo].pl_exam on PATDIREC.PL_EXAM_ID=pl_exam.PL_EXAM_ID
join [10.255.69.10].[med_euroonco_new].[dbo].pl_ex_gr on pl_ex_gr.pl_ex_gr_ID=pl_exam.PL_EX_GR_ID
join [10.255.69.10].[med_euroonco_new].[dbo].PATDIREC_DRUGS on PATDIREC_DRUGS.PATDIREC_ID=PATDIREC.PATDIREC_ID
left join [10.255.69.10].[med_euroonco_new].[dbo].[PATDIREC_DRUGS_DET] on PATDIREC_DRUGS.[PATDIREC_DRUGS_ID]=[PATDIREC_DRUGS_DET].[PATDIREC_DRUGS_ID]
left join PL_EXAM as new on cast(pl_exam.PL_EXAM_ID as varchar(32))=new.CODE_AK
where len([PR_TEMPLATE_SCHEMES].code)>0
  and PATDIREC.PR_TEMPLATE_SCHEMES_id>700
--and pl_ex_gr.PL_EX_GR_ID not in (24,25,32,33,38,43,45,46,47,48,49,50,51,52,53)
--and new.PL_EXAM_ID is null

order by PATDIREC.[PATDIREC_ID]

--select MIN(PATDIREC_DRUGS_id) from [10.255.69.10].[med_euroonco_new].[dbo].PATDIREC_DRUGS



