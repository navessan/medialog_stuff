select
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