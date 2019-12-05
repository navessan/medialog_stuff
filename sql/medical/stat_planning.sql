select top 1 
(COUNT(DISTINCT planning.PATIENTS_ID )) CNT_PAT,(COUNT(planning.planning_id )) CNT_PLAN
from planning
where planning.create_DATE_time>DATEADD(day, DATEDIFF(day, 0, getdate()), 0)
and planning.create_DATE_time<DATEADD(day, DATEDIFF(day, 0, getdate()), +1)

