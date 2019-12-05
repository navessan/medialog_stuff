/*
server=SRV-SVC\PARSEC3
database=Parsec3Trans

rs\rs
*/

declare @tz int
set @tz=3

select distinct top 500
dateadd(dd,datediff(dd,0,logs.TRAN_DATE),0) date,
LAST_NAME+' '+FIRST_NAME+' '+MIDDLE_NAME as tranuser

--logs.tranuser, logs.tranuserid

,dateadd(hour,@tz,tran_start.TRAN_DATE) as enterTime
,place_start.COMP_DESC as enterPlace

,dateadd(hour,@tz,tran_end.TRAN_DATE) as exitTime
,place_end.COMP_DESC as exitPlace

--,place_start.*
from [Parsec3Trans].[dbo].[TRANSLOG] logs
join [Parsec3].[dbo].[PERSON] on PERSON.PERS_ID=logs.USR_ID
left join [Parsec3Trans].[dbo].[TRANSLOG] tran_start on tran_start.rid=(
	select top 1 st.rid
	from [Parsec3Trans].[dbo].[TRANSLOG] st
	where st.USR_ID=logs.USR_ID
	and st.TRAN_DATE>dateadd(dd,datediff(dd,0,logs.TRAN_DATE),0)
	and st.TRANTYPE_ID in( 590145, 590144)
	order by st.TRAN_DATE
)
left join [Parsec3Trans].[dbo].[TRANSLOG] tran_end on tran_end.rid=(
	select top 1 st.rid
	from [Parsec3Trans].[dbo].[TRANSLOG] st
	where st.USR_ID=logs.USR_ID
	and st.TRAN_DATE>dateadd(dd,datediff(dd,0,logs.TRAN_DATE),0)
	and st.TRAN_DATE<dateadd(dd,datediff(dd,0,logs.TRAN_DATE)+1,0)
	and st.TRANTYPE_ID in( 590145, 590144)
	order by st.TRAN_DATE desc
)
left join [Parsec3].[dbo].[COMPONENT] place_start on place_start.COMP_ID=tran_start.COMP_ID
left join [Parsec3].[dbo].[COMPONENT] place_end on place_end.COMP_ID=tran_end.COMP_ID

where logs.TRANTYPE_ID in( 590145, 590144)
and logs.TRAN_DATE> '2016-02-09 00:00:00'
order by tranuser
