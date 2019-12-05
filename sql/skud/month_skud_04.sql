
set nocount on;

declare 
	@DateFrom DateTime
	,@DateTo DateTime
	,@D datetime
	,@LastMonth int

select 
	@D=GETDATE()
	,@LastMonth=1		--нужный мес€ц из прошедших

/*
SELECT DATEADD(month, DATEDIFF(month, 0, @D), 0) AS StartOfMonth
		,DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, @D) + 1, 0))	as EndOfMonth
*/

SELECT @DateFrom=DATEADD(month, DATEDIFF(month, 0, @D)-@LastMonth, 0)
	,@DateTo=DATEADD(d, -1, DATEADD(m, DATEDIFF(MONTH, 0, @D)+1-@LastMonth, 0))

/*
SELECT @DateFrom={ts'2016-10-28 00:00:00.000'}
	,@DateTo={ts'2016-10-31 00:00:00.000'}
*/

IF OBJECT_ID(N'z_skud') is not null
DROP TABLE [dbo].[z_skud]

create table z_skud(d datetime,dep varchar(512),name varchar(512),start_time datetime,start_place varchar(512),end_time datetime,end_place varchar(512),work datetime)
--convert(varchar(20),L_start.DateTime,108) as start_time

declare @i as int
	,@query as varchar(max)
	,@cmd as varchar(max)
	,@cmd2 as varchar(max)

select @query=
'SELECT
parent.NAME as dep
,p.NAME
,log_start.LOGTIME as start_time
,dev_start.NAME as start_place
,log_end.LOGTIME as end_time
,dev_end.NAME as end_place
from(	SELECT
	t.EMPHINT
	,(SELECT ls.ID
		FROM LOGS AS ls
		WHERE ls.EMPHINT=t.EMPHINT AND TO_DAYS(ls.LOGTIME)=TO_DAYS(now())-_COUNT_
		ORDER BY logtime
		LIMIT 1
	) AS start_id
	,(SELECT ls.ID
		FROM LOGS AS ls
		WHERE ls.EMPHINT=t.EMPHINT AND TO_DAYS(ls.LOGTIME)=TO_DAYS(now())-_COUNT_
		ORDER BY logtime DESC
		LIMIT 1
	) AS end_id
	FROM
		(SELECT DISTINCT l.EMPHINT
		FROM `tc-db-log`.logs AS l
		WHERE TO_DAYS(l.LOGTIME)=TO_DAYS(now())-_COUNT_
		) AS t
) AS t2
JOIN `tc-db-main`.personal AS p ON t2.EMPHINT=p.ID
JOIN `tc-db-main`.personal AS parent ON p.PARENT_ID=parent.ID
join `tc-db-log`.logs AS log_start on log_start.ID=t2.start_id
join `tc-db-log`.logs AS log_end on log_end.ID=t2.end_id
join `tc-db-main`.devices as dev_start on dev_start.ID=log_start.DEVHINT
join `tc-db-main`.devices as dev_end on dev_end.ID=log_end.DEVHINT
where
p.PARENT_ID<>74 and
p.ID<>66
ORDER BY parent.NAME,p.NAME
'
select @cmd=
----------------- 
'insert into z_skud
(dep,name,d,start_time,start_place,end_time,end_place,work)
SELECT 
dep
,name
,DATEADD(d,datediff(d,0,start_time),0) as d
,start_time
,start_place
,end_time
,end_place
,end_time -start_time as work
FROM openquery(SKUD,'''+ @query+''')'
---------------

select @D = @DateFrom	
select @D, @DateTo
select @i=DATEDIFF(d,@d,getdate())	--Day offset for mysql query


while @D <= @DateTo
begin
------
  	select @cmd2=REPLACE(@cmd,'_COUNT_',CAST(@i as varchar(4)))
	--select @i, @cmd2
	exec(@cmd2)
  	
  	select @D = @D + 1
  	select @i=DATEDIFF(d,@D,getdate())
------  	
end

/*
итоговый результат
*/ 

select
*
from z_skud

/*
select 
dep,name
,round(sum(
datediff(hh, 0, work ) 
+
cast(DATEPART(MINUTE,work) as float)/60
),2) as hour_sum
,max(case when datepart(DAY,d)=1 then convert(varchar(20),work,108) else '' end) as [1]
,max(case when datepart(DAY,d)=2 then convert(varchar(20),work,108) else '' end) as [2]
,max(case when datepart(DAY,d)=3 then convert(varchar(20),work,108) else '' end) as [3]
,max(case when datepart(DAY,d)=4 then convert(varchar(20),work,108) else '' end) as [4]
,max(case when datepart(DAY,d)=5 then convert(varchar(20),work,108) else '' end) as [5]
,max(case when datepart(DAY,d)=6 then convert(varchar(20),work,108) else '' end) as [6]
,max(case when datepart(DAY,d)=7 then convert(varchar(20),work,108) else '' end) as [7]
,max(case when datepart(DAY,d)=8 then convert(varchar(20),work,108) else '' end) as [8]
,max(case when datepart(DAY,d)=9 then convert(varchar(20),work,108) else '' end) as [9]
,max(case when datepart(DAY,d)=10 then convert(varchar(20),work,108) else '' end) as [10]
,max(case when datepart(DAY,d)=11 then convert(varchar(20),work,108) else '' end) as [11]
,max(case when datepart(DAY,d)=12 then convert(varchar(20),work,108) else '' end) as [12]
,max(case when datepart(DAY,d)=13 then convert(varchar(20),work,108) else '' end) as [13]
,max(case when datepart(DAY,d)=14 then convert(varchar(20),work,108) else '' end) as [14]
,max(case when datepart(DAY,d)=15 then convert(varchar(20),work,108) else '' end) as [15]
,max(case when datepart(DAY,d)=16 then convert(varchar(20),work,108) else '' end) as [16]
,max(case when datepart(DAY,d)=17 then convert(varchar(20),work,108) else '' end) as [17]
,max(case when datepart(DAY,d)=18 then convert(varchar(20),work,108) else '' end) as [18]
,max(case when datepart(DAY,d)=19 then convert(varchar(20),work,108) else '' end) as [19]
,max(case when datepart(DAY,d)=20 then convert(varchar(20),work,108) else '' end) as [20]
,max(case when datepart(DAY,d)=21 then convert(varchar(20),work,108) else '' end) as [21]
,max(case when datepart(DAY,d)=22 then convert(varchar(20),work,108) else '' end) as [22]
,max(case when datepart(DAY,d)=23 then convert(varchar(20),work,108) else '' end) as [23]
,max(case when datepart(DAY,d)=24 then convert(varchar(20),work,108) else '' end) as [24]
,max(case when datepart(DAY,d)=25 then convert(varchar(20),work,108) else '' end) as [25]
,max(case when datepart(DAY,d)=26 then convert(varchar(20),work,108) else '' end) as [26]
,max(case when datepart(DAY,d)=27 then convert(varchar(20),work,108) else '' end) as [27]
,max(case when datepart(DAY,d)=28 then convert(varchar(20),work,108) else '' end) as [28]
,max(case when datepart(DAY,d)=29 then convert(varchar(20),work,108) else '' end) as [29]
,max(case when datepart(DAY,d)=30 then convert(varchar(20),work,108) else '' end) as [30]
,max(case when datepart(DAY,d)=31 then convert(varchar(20),work,108) else '' end) as [31]
from z_skud as tbl
group by 
dep,name

*/