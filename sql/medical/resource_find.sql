select
*
from RES_LIST
where RESOURCE_CODE='6480'

declare @RESOURCE_ID int

set @RESOURCE_ID=24115

select
*
from RES_ALIAS
where RESOURCE_ID=@RESOURCE_ID

/*
select MASTER_RESOURCE_ID
from RES_LINKS
where RESOURCE_ID=@RESOURCE_ID
*/

select
MODELS.ModeleName,
* 
from EXAMENS
left join MODELS on MODELS.Models_ID=EXAMENS.Models_ID
where FRM_NAME in(
	select RESOURCE_CODE
	from RES_LIST
	where RESOURCE_ID in
	(select MASTER_RESOURCE_ID
	from RES_LINKS
	where RESOURCE_ID=@RESOURCE_ID
	)
	
)