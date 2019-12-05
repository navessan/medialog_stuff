
set nocount on;

declare @i as int
	,@cmd as varchar(max)
	,@query as varchar(max)
select @i=1

select @query=
'SELECT distinct
parent.NAME	as dep
,p.name
,(select ls.LOGTIME 
	from logs as ls 
	where ls.EMPHINT=l.EMPHINT
	and TO_DAYS(ls.LOGTIME)=TO_DAYS(now()-'+CAST(@i as varchar(2))+')
	ORDER BY logtime
	limit 1
) as starttime
,(select ls.LOGTIME 
	from logs as ls 
	where ls.EMPHINT=l.EMPHINT
	and TO_DAYS(ls.LOGTIME)=TO_DAYS(now())
	ORDER BY logtime DESC
	limit 1
) as endtime
FROM `tc-db-log`.logs AS l
JOIN `tc-db-main`.personal AS p ON l.EMPHINT=p.ID
join `tc-db-main`.personal AS parent on p.PARENT_ID=parent.ID
where TO_DAYS(l.LOGTIME)=TO_DAYS(now())
and p.PARENT_ID not in(74)
and p.ID<>66
ORDER BY parent.NAME,p.NAME
'

select @cmd=
----------------- 
'SELECT 
dep
,name
,DATEADD(d,datediff(d,0,starttime),0) as date
,starttime
,endtime
,endtime -starttime as work
FROM openquery(SKUD,'''+ @query+''')'
---------------

--select @cmd
exec(@cmd)