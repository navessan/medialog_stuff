SET DATEFIRST 1
SET LANGUAGE RUSSIAN
declare @checkdate datetime
declare @INTERVAL_STARTFROM datetime
declare @INTERVAL_WORK int
declare @INTERVAL_OFF int

select @INTERVAL_STARTFROM='20110101'
select @INTERVAL_WORK=1, @INTERVAL_OFF=1
select @checkdate='20110503'
----------
declare @num int, @week int
declare @iday int, @idaycnt int, @iday_prev int
declare @day datetime, @date datetime
declare @weekday varchar(16)
DECLARE dCursor CURSOR FOR
select number, DATEADD(dd,Number,@INTERVAL_STARTFROM) AS [WorkDays]
from master..spt_values N
where type='P' AND number between 0 AND 400

declare @table table(
	num int NULL,
	workday datetime NULL,
	weekday varchar(16) NULL,
	week int NULL,
	iday int NULL,
	idaycnt int NULL
)

OPEN dCursor;
FETCH NEXT FROM dCursor into @num, @date;
WHILE @@FETCH_STATUS = 0
   BEGIN
	set @weekday=DATENAME(weekday,@date)
	set @week=DATEPART(week,@date)-DATEPART(week,DATEADD(day,1-day(@date),@date))+1
	set @iday=DATEDIFF(day,DATEADD(day,1-day(@date),@date),@date)/7+1
	if(@iday_prev=@iday) 
		set @idaycnt=@idaycnt+1
		else set @idaycnt=1
	set @iday_prev=@iday
	insert into @table values (@num, @date,@weekday,@week,@iday,@idaycnt)
      FETCH NEXT FROM dCursor into @num, @date;
   END;
CLOSE dCursor;
DEALLOCATE dCursor;

select * from @table








