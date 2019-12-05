declare @p3 datetime
set @p3='1900-01-01 00:00:00:000'
declare @p4 datetime
set @p4='1900-01-01 00:00:00:000'
declare @p5 datetime
set @p5='1900-01-01 00:20:00:000'
declare @p6 int
set @p6=0
exec pl_GetSubjDayParam 326,'2011-07-18 00:00:00:000',@p3 output,@p4 output,@p5 output,@p6 output
select @p3 StartTime, @p4 EndTime, @p5 IntervalDuration, @p6 DayEnabled
