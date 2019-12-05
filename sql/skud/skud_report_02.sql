alter procedure [dbo].[skud_report]
as
begin

declare @date datetime
	,@tableHTML  NVARCHAR(MAX)
	,@emails NVARCHAR(MAX)
	
set @emails='nov@m'

SET @tableHTML =
    N'<H1></H1>' +
    N'<table bordercolor="green" border="2">' +
    N'<tr bgcolor="#F7FF47"><th>Отдел</th><th>ФИО</th>
    <th>Первый проход</th>
    <th>Последний проход</th>
    <th>Время работы</th>
    </tr>'


select @tableHTML =@tableHTML +CAST(
(---------------
select
td=t.[dep]
,'' ,td=t.[name]
,'' ,td=t.[starttime]
,'' ,td=t.[endtime]
,'' ,td=t.[work]
,''
from (

----------------- 
SELECT 
dep
,name
,convert(varchar(20),starttime,120) as starttime
,convert(varchar(20),endtime,120) as endtime
,convert(varchar(20),(endtime -starttime),108) as work
FROM openquery(SKUD, 'SELECT distinct
parent.NAME	as dep
,p.name
,(select ls.LOGTIME 
	from logs as ls 
	where ls.EMPHINT=l.EMPHINT
	and TO_DAYS(ls.LOGTIME)=TO_DAYS(now())
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
and p.PARENT_ID not in(8,74)
and p.ID<>66
ORDER BY parent.NAME,p.NAME
')

---------------
) as t
order by t.dep
for XML PATH('tr'), TYPE
)
as nvarchar(max))


select @tableHTML=@tableHTML+
    N'</table>' +
    N'<HR>'+
    N'<b>С уважением.</b>';

--select @tableHTML

 
EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'm24',
	@recipients=@emails,
    @subject = 'Отчет по СКУД',
    @body = @tableHTML,
    @body_format = 'HTML' ;    
   
    
end    
GO


