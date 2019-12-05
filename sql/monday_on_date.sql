
declare @week datetime
	,@sklad int

select @week = {ts '2016-03-13 00:00:00.000'}


set datefirst 1

SELECT DATEADD(wk, DATEDIFF(wk,0,@week), 0)
--+dateadd(d,6,0)


/* Monday on date */
SELECT DATEADD(d,0 -((DATEPART(WEEKDAY, @week) - DATEPART(dw, '19000101') + 7) % 7), @week)


select dateadd(d,7,{ts '2016-03-14 00:00:00.000'})


