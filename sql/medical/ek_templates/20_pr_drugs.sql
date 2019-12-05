declare @offset_PR_DRUGS_ID int

select @offset_PR_DRUGS_ID=1000

/*
insert into PR_DRUGS (	[PR_DRUGS_ID]
      ,[CODE]
      ,[FULL_NAME]
      ,[ALTER_CODE]
      ,[DESCRIPTION]
      ,[IS_MIXT]
      ,[IS_COMBINED]
      ,[DM_PACK_RELEASE_ID]
      ,[PACKING_QUANTITY]
      ,[ACTIVE_QUANTITY]
      ,[PACKING_MEASURE_ID]
      ,[ACTIVE_MEASURE_ID])
*/  
SELECT
	[PR_DRUGS_ID]+@offset_PR_DRUGS_ID
      ,[PR_drugs].[CODE]
      ,[PR_drugs].[FULL_NAME]
      ,[PR_drugs].[ALTER_CODE]
      ,[PR_drugs].[DESCRIPTION]
      ,[PR_drugs].[IS_MIXT]
      ,[PR_drugs].[IS_COMBINED]
      ,[PR_drugs].[DM_PACK_RELEASE_ID]
      ,[PR_drugs].[PACKING_QUANTITY]
      ,[PR_drugs].[ACTIVE_QUANTITY]
      ,[PR_drugs].[PACKING_MEASURE_ID]
      ,[PR_drugs].[ACTIVE_MEASURE_ID]
--      ,ek.label
--      ,new.label
  FROM [10.255.69.10].[med_euroonco_new].[dbo].[PR_drugs]
--left join [10.255.69.10].[med_euroonco_new].[dbo].DM_MEASURE ek on [PR_drugs].ACTIVE_MEASURE_ID=ek.DM_MEASURE_ID
--left join DM_MEASURE new										on [PR_drugs].ACTIVE_MEASURE_ID=new.DM_MEASURE_ID

left join [10.255.69.10].[med_euroonco_new].[dbo].DM_MEASURE ek on [PR_drugs].[PACKING_MEASURE_ID]=ek.DM_MEASURE_ID
left join DM_MEASURE new										on [PR_drugs].[PACKING_MEASURE_ID]=new.DM_MEASURE_ID

--left join [10.255.69.10].[med_euroonco_new].[dbo].DM_PACK_RELEASE ek on [PR_drugs].[DM_PACK_RELEASE_ID]=ek.DM_PACK_RELEASE_ID
--left join DM_PACK_RELEASE new										on [PR_drugs].[DM_PACK_RELEASE_ID]=new.DM_PACK_RELEASE_ID

-- left join [medialog].[dbo].pl_ex_gr as new on new.pl_ex_gr_id=[PR_TEMPLATE_SCHEMES].pl_ex_gr_id 
where 
--ISNULL(ek.label,'')<>ISNULL(new.label,'')
--and new.DM_PACK_RELEASE_ID is null
[PR_DRUGS_ID] not in
(select [PR_DRUGS_ID]-@offset_PR_DRUGS_ID from [PR_DRUGS])

