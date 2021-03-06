/*
--Free System Cache
DBCC FREESYSTEMCACHE
--Drop Clean Buffers
DBCC DROPCLEANBUFFERS
--Free Procedure Cache
DBCC FREEPROCCACHE
*/
-----------------------
IF OBJECT_ID('#test_table','U') IS NOT NULL 
	drop table #test_table
IF OBJECT_ID('test_result_table','U') IS NOT NULL 
	drop table test_result_table
IF OBJECT_ID('report_table','U') IS NOT NULL 
	drop table report_table

CREATE TABLE report_table
   (time_ms int null
	,guid varchar(36)  NULL
	,time datetime  NULL)

set NOCOUNT on

DECLARE 
	@cnt INT
	,@cnt2 INT
	,@cx int
	,@cy int
	,@start_time datetime
	,@end_time datetime
	,@test_date datetime
	,@test_GUID varchar(36)

SET @cnt=100000
SET @cnt2=5



set @cy=0
WHILE (@cy < @cnt2)
BEGIN
set @cy=@cy+1

set @cx=0
set @start_time=getdate()

IF OBJECT_ID('#test_table','U') IS NULL 
CREATE TABLE #test_table
   (id int null
	,guid varchar(36)  NULL
	,time datetime  NULL)

WHILE (@cx < @cnt)
BEGIN
	set @cx=@cx+1
	set @test_date=getdate()
	--set @test_GUID=NEWID()
	--set @test_GUID=convert(datetime, convert(varchar(10), @test_date, 120), 120)
	set @test_GUID=dateadd(day,0,datediff(day,0,@test_date))
	insert into #test_table values (@cx, @test_GUID,@test_date)

	--select @test_GUID=max(guid) from test_table
END
/*
select 
sum(cast(time as int)) sum_v, count(id) count_v, guid
into test_result_table
from test_table
group by guid
having count(id)>1
order by guid
*/
drop table #test_table
--drop table test_result_table

set @end_time=getdate()

select datediff(ms,@start_time, @end_time) time_ms,@end_time-@start_time duration_time

insert into report_table values(datediff(ms,@start_time, @end_time),null,@end_time-@start_time)

end

select * from report_table
join (select avg(time_ms) avg_ms from report_table) avt on 1=1