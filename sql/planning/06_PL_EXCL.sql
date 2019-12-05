select 
PL_EXCL.NAME
,PL_LEG.NAME
,PL_LEG.COLOR
,FROM_DATE
,FROM_TIME
,TO_DATE
,TO_TIME
--,* 
from PL_EXCL 
inner join PL_LEG on PL_LEG.PL_LEG_ID=PL_EXCL.PL_LEG_ID 
where  PL_SUBJ_ID in (474) 
--and  TO_DATE >= '20110305 00:00:00.000' and TO_DATE <= '20380820 00:00:00.000'
--and TO_DATE >= getdate() 
--and TO_DATE <= getdate()
order by TO_DATE,FROM_DATE