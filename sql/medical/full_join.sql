/* TfStatPrm.ReportRequest 'FIN_AGENT_RAS_AMB' */
declare 
	@date_start datetime
	,@date_end datetime
select 
	@date_start = {ts '2017-07-01 00:00:00.000'}
	,@date_end = {ts '2017-07-05 00:00:00.000'}


select top 500
C.CALLS_ID
,c.CALL_DATETIME
,web.US_WEB_COMAGIC_CALLS_ID
,web.call_date
,web.MEDIALOG_CALL_ID
,web.*
FROM
 CALLS as C
 full join US_WEB_COMAGIC_CALLS web on C.CALLS_ID=web.MEDIALOG_CALL_ID
WHERE
(
	datediff(d,@date_start, C.CALL_DATETIME)>=0 and 
	datediff(d,@date_end, C.CALL_DATETIME)<=0
)
or	
(
	datediff(d,@date_start, convert(datetime,web.call_date,120) )>=0 and 
	datediff(d,@date_end,  convert(datetime,web.call_date,120) )<=0
)
order by coalesce(convert(datetime,web.call_date,120),c.CALL_DATETIME)


/*
select
*
from US_WEB_COMAGIC_CALLS web
where
	datediff(d,@date_start, convert(datetime,web.call_date,120) )>=0 and 
	datediff(d,@date_end,  convert(datetime,web.call_date,120) )<=0 and 
	web.MEDIALOG_CALL_ID is null
*/

select
C.CALLS_ID
,c.CALL_DATETIME
,web.US_WEB_COMAGIC_CALLS_ID
,web.call_date
,web.MEDIALOG_CALL_ID
,web.*
from CIM10 m
left join CALLS as C on m.CIM10_ID=1 
					and datediff(d,@date_start, C.CALL_DATETIME)>=0 
					and datediff(d,@date_end, C.CALL_DATETIME)<=0
left join US_WEB_COMAGIC_CALLS web on (m.CIM10_ID=2 or C.CALLS_ID=web.MEDIALOG_CALL_ID) 
					and datediff(d,@date_start, convert(datetime,web.call_date,120) )>=0 
					and datediff(d,@date_end, convert(datetime,web.call_date,120) )<=0
left join CALLS as C2			   on (m.CIM10_ID=2 and C2.CALLS_ID=web.MEDIALOG_CALL_ID) 
					and datediff(d,@date_start, C2.CALL_DATETIME)>=0 
					and datediff(d,@date_end, C2.CALL_DATETIME)<=0
where CIM10_ID in (1,2)
and (web.US_WEB_COMAGIC_CALLS_ID is null or c2.CALLS_ID is null)
order by coalesce(convert(datetime,web.call_date,120),c.CALL_DATETIME)

/*
https://www.xaprb.com/blog/2006/05/26/how-to-write-full-outer-join-in-mysql/ 
*/