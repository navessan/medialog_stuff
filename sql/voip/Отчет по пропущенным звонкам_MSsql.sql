CREATE procedure [dbo].[US_aster_report]
as
begin

if not exists(
SELECT 
*
FROM openquery([ASTERISK], 'select
cel.eventtime
from cel
left join cel as c2 on c2.linkedid=cel.uniqueid and c2.eventtype=''BRIDGE_ENTER''
where 
cel.context=''from-trunk'' and
to_days(cel.eventtime)=to_days(now()) and 
cel.eventtype=''CHAN_START'' and
cel.uniqueid=cel.linkedid and
c2.id is null
limit 1000
')
)
begin
	select 'no calls'
	return
end

declare @date datetime
	,@tableHTML  NVARCHAR(MAX)
	,@emails NVARCHAR(MAX)
	,@bcc nvarchar(max)
		
select @emails='f@gmail.com;S@.ru;'
	,@bcc=''


SET @tableHTML =
    N'<H1></H1>' +
    N'<table bordercolor="green" border="2">' +
    N'<tr bgcolor="#F7FF47"><th>Дата</th>
    <th>Длительность</th>
    <th>Абонент</th>
    <th>Входящий номер</th>
    <th>Успешный звонок</th>
    </tr>'


select @tableHTML =@tableHTML +CAST(
(---------------
select
td=isnull(t.[eventtime],'-')
,'' ,td=isnull(t.[duration],'-')
,'' ,td=isnull(t.[cid_num],'-')
,'' ,td=isnull(t.[exten],'-')
,'' ,td=isnull(t.[redial],'-')
,''
from (

----------------- 
SELECT 
convert(varchar(20),eventtime,120) as eventtime
,convert(varchar(20),duration,120) as duration
,cid_num
,exten
,convert(varchar(20),redial,120) as redial
FROM openquery([ASTERISK], 'select
cel.eventtime
,ev_end.eventtime-cel.eventtime as duration
,cel.cid_num
,cel.exten
,(select eventtime 
	from cel as rcel
	where rcel.cid_num=cel.cid_num and
	to_days(rcel.eventtime)=to_days(cel.eventtime) and
	rcel.eventtype=''BRIDGE_ENTER''
	order by rcel.eventtime desc
	limit 1
) as redial
from cel
left join cel as c2 on c2.linkedid=cel.uniqueid and c2.eventtype=''BRIDGE_ENTER''
left join cel as ev_end on ev_end.linkedid=cel.uniqueid and ev_end.eventtype=''LINKEDID_END''
where 
cel.context=''from-trunk'' and
to_days(cel.eventtime)=to_days(now()) and 
cel.eventtype=''CHAN_START'' and
cel.uniqueid=cel.linkedid and
c2.id is null
limit 1000
')
---------------
) as t
order by t.eventtime
for XML PATH('tr'), TYPE
)
as nvarchar(max))


select @tableHTML=@tableHTML+
    N'</table>' +
    N'<HR>'+
    N'<b>С уважением.</b>';

--select @tableHTML

 
EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'm',
	@recipients=@emails,
	@blind_copy_recipients=@bcc,
    @subject = 'Мед: Отчет по пропущенным звонкам',
    @body = @tableHTML,
    @body_format = 'HTML' ;    
   
    
end    
