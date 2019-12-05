/*select
*
from PR_DRUGS
*/
/*
select
z.DM_PACK_RELEASE_ID
,z.LABEL
,ek.*
from DM_PACK_RELEASE z
left join [10.255.69.10].[med_euroonco_new].[dbo].DM_PACK_RELEASE ek on z.DM_PACK_RELEASE_ID=ek.DM_PACK_RELEASE_ID
*/

/*
261	Тромбоконцентрат	300
262	Плазма крови		301
263	эр.взвесь			302
*/

select
z.DM_MEASURE_ID
,z.LABEL
,z.code
,z.FULL_NAME
,ek.*
from DM_MEASURE z
full join [10.255.69.10].[med_euroonco_new].[dbo].DM_MEASURE ek on z.DM_MEASURE_ID=ek.DM_MEASURE_ID


/*

*/

