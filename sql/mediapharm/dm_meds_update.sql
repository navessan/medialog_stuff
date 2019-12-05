/*select *
update DM_COSTS set DM_MEASURE_ID=7
from DM_COSTS
where DM_MEASURE_ID=4
and LABEL like '%дез%'
*/

/*
update M set
DM_COSTS_id=null
from DM_MEDS M

truncate table DM_COSTS

update v
set LAST_VALUE = 0
      from ID_VALUES V
      where Key_NAME = 'dm_costs'
*/      
/*
UPDATE DM_MEDS 
SET COST_PACK = 1 
WHERE DM_COSTS_ID is not null
*/


select *
--update DM_SERV_MEDS set DM_SERV_MEDS.QUANTITY=DM_SERV_MEDS.QUANTITY*1000
from DM_SERV_MEDS
JOIN DM_COSTS DM_COSTS ON DM_COSTS.DM_COSTS_ID = DM_SERV_MEDS.DM_COSTS_ID

where DM_MEASURE_ID=7
and DM_SERV_MEDS.QUANTITY<0.2