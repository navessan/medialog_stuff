
declare @old int
		,@new int

select @old=342
	,@new=211

update PL_EX_GR set
PL_EX_GR_ID=@new
where PL_EX_GR_ID=@old



select top 1000
*
from 
pl_ex_gr
--PR_TEMPLATE_SCHEMES
--order by pl_ex_gr_id desc
--where TYPE=1

