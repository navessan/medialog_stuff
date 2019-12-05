/*
select MAX(patdirec_id)
from PATDIREC

*/
insert into [PR_TEMPLATE_SCHEMES]
(PR_TEMPLATE_SCHEMES_ID,CODE,FULL_NAME,PL_EX_GR_ID,PERSONAL_SCHEME,description)

select 
PR_TEMPLATE_SCHEMES_ID,CODE,FULL_NAME,PL_EX_GR_ID,PERSONAL_SCHEME,description

from [10.255.69.10].[med_euroonco_new].[dbo].[PR_TEMPLATE_SCHEMES]
where len([PR_TEMPLATE_SCHEMES].code)>0
  and PR_TEMPLATE_SCHEMES_id>700
  and len(isnull(CODE,''))>0 
  and len(isnull(FULL_NAME,''))>0 
and PR_TEMPLATE_SCHEMES_id not in (select PR_TEMPLATE_SCHEMES_ID from PR_TEMPLATE_SCHEMES)

order by PR_TEMPLATE_SCHEMES_ID


/*
select 
PR_TEMPLATE_SCHEMES_ID,CODE,FULL_NAME,PL_EX_GR_ID,PERSONAL_SCHEME,description
,*
from PR_TEMPLATE_SCHEMES as s
*/