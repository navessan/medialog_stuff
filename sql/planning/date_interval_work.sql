declare @date datetime
declare @INTERVAL_STARTFROM datetime
declare @INTERVAL_WORK int
declare @INTERVAL_OFF int

select @INTERVAL_STARTFROM='20110501'
select @INTERVAL_WORK=2, @INTERVAL_OFF=1
select @date='20110504'
----------
select number, DATEADD(dd,Number,@INTERVAL_STARTFROM) AS [WorkDays]
from master..spt_values N
where type='P' AND number between 0 AND 100
and (number)%(@INTERVAL_WORK+@INTERVAL_OFF)<=(@INTERVAL_WORK-1)
---------
select @date date
,'work'
where 
(DATEDIFF(day,@INTERVAL_STARTFROM,@date))%(@INTERVAL_WORK+@INTERVAL_OFF)<=(@INTERVAL_WORK-1)



