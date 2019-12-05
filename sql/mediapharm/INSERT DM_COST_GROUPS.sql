INSERT INTO [medialog].[dbo].[DM_COST_GROUPS]
           ([DM_COST_GROUPS_ID]
           ,[LABEL]
           ,COST_GROUP_TYPE)
select 
ROW_NUMBER() over(order by DM_COST_GROUPS_label) as num
,DM_COST_GROUPS_label
,'M'
from z_costs
where DM_COST_GROUPS_label is not null
group by DM_COST_GROUPS_label

