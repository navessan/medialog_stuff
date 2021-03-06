/*
select MAX(DIR_ANSW_ID)
from DIR_ANSW

*/

declare @offset_PATDIREC_ID int
		,@offset_DIR_ANSW_ID int
		
select @offset_PATDIREC_ID=20000
	  ,@offset_DIR_ANSW_ID=20000

/*
insert into DIR_ANSW
([DIR_ANSW_ID]
      ,[PATDIREC_ID]
      ,[ANSW_STATE]
      ,[PLANE_DATE]
      ,[DRUG_DOSE]
      ,[WRITE_OFF]
      ,[CHANGED]
      ,[PACK_MEASURE_DOSE]
      ,[CANCEL_PAY])
*/
select 
t.*
,t.DESCRIPTION
,p_new.DESCRIPTION as new_des
from
(
select
 @offset_DIR_ANSW_ID+ROW_NUMBER()over (order by PATDIREC.[PATDIREC_ID]) as [DIR_ANSW_ID]
,@offset_PATDIREC_ID+Rank()over (order by PATDIREC.[PATDIREC_ID]) as [PATDIREC_ID]

--,PATDIREC.PL_EXAM_ID as old_pl_exam_id
--,pl_exam.NAME,
--new.NAME
--,PATDIREC.[PATDIREC_ID]
--,d.*
-- ,[DIR_ANSW_ID]
      ,PATDIREC.[PATDIREC_ID] as old_id
/*      ,[ANSW_STATE]
      ,[PLANE_DATE]
      ,[DRUG_DOSE]
      ,[WRITE_OFF]
      ,[CHANGED]
      ,[PACK_MEASURE_DOSE]
      ,[CANCEL_PAY]
      ,PATDIREC.DESCRIPTION
      ,PATDIREC.PR_TEMPLATE_SCHEMES_id
,'|' '|' */
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
/*,'|' '|'
,ROW_NUMBER()over (order by PATDIREC.[PATDIREC_ID]) as [PATDIREC_DRUGS.PATDIREC_DRUGS_ID]
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
,'|' '|'
	  ,ROW_NUMBER()over (order by PATDIREC.[PATDIREC_ID]) as [PATDIREC_DRUGS_DET.PATDIREC_DRUGS_DET_ID]
      ,ROW_NUMBER()over (order by PATDIREC.[PATDIREC_ID]) as [PATDIREC_DRUGS_DET.PATDIREC_DRUGS_ID]
      ,[PATDIREC_DRUGS_DET].[PR_DRUGS_ID]+1000 as [PR_DRUGS_ID]
      ,[PATDIREC_DRUGS_DET].[DM_MEASURE_ID]
      ,[PATDIREC_DRUGS_DET].[DOSE]
*/      
from [10.255.69.10].[med_euroonco_new].[dbo].PATDIREC
join [10.255.69.10].[med_euroonco_new].[dbo].[PR_TEMPLATE_SCHEMES] on PATDIREC.PR_TEMPLATE_SCHEMES_ID=[PR_TEMPLATE_SCHEMES].PR_TEMPLATE_SCHEMES_ID
--left join [10.255.69.10].[med_euroonco_new].[dbo].dir_answ as d on d.PATDIREC_ID=PATDIREC.PATDIREC_ID
join [10.255.69.10].[med_euroonco_new].[dbo].pl_exam on PATDIREC.PL_EXAM_ID=pl_exam.PL_EXAM_ID
join [10.255.69.10].[med_euroonco_new].[dbo].pl_ex_gr on pl_ex_gr.pl_ex_gr_ID=pl_exam.PL_EX_GR_ID
join [10.255.69.10].[med_euroonco_new].[dbo].PATDIREC_DRUGS on PATDIREC_DRUGS.PATDIREC_ID=PATDIREC.PATDIREC_ID
left join [10.255.69.10].[med_euroonco_new].[dbo].[PATDIREC_DRUGS_DET] on PATDIREC_DRUGS.[PATDIREC_DRUGS_ID]=[PATDIREC_DRUGS_DET].[PATDIREC_DRUGS_ID]
left join PL_EXAM as new on cast(pl_exam.PL_EXAM_ID as varchar(32))=new.CODE_AK
where len([PR_TEMPLATE_SCHEMES].code)>0
  and PATDIREC.PR_TEMPLATE_SCHEMES_id>700
--and pl_ex_gr.PL_EX_GR_ID not in (24,25,32,33,38,43,45,46,47,48,49,50,51,52,53)
--and new.PL_EXAM_ID is null

--order by PATDIREC.[PATDIREC_ID]
) as t
left join PATDIREC p_new on p_new.PATDIREC_ID=t.PATDIREC_ID

--where p_new.PATDIREC_ID is null
order by t.PATDIREC_ID



