/*
10.1.1.1\parsecdb
rs\rs
*/


select distinct top 500
dateadd(dd,datediff(dd,0,logs.trandatetime),0) date,
logs.tranuser, logs.tranuserid
/*
,(case when tran_start.trancode=64 then 'бунд'
when tran_start.trancode=65 then 'бшунд'
end)as enter_direction
*/
,tran_start.trandatetime as enterTime
,tran_start.tranArea as enterPlace

/*,(case when tran_start.trancode=64 then 'бунд'
when tran_start.trancode=65 then 'бшунд'
end)as exit_direction
*/
,tran_end.trandatetime as exitTime
,tran_end.tranArea as exitPlace
/*,(
select top 1 st.trandatetime
from translog st
where st.tranuserID=logs.tranuserID
and st.trandatetime>dateadd(dd,datediff(dd,0,logs.trandatetime),0)
order by st.trandatetime
)start
,(
select top 1 st.trandatetime
from translog st
where st.tranuserID=logs.tranuserID
and st.trandatetime>dateadd(dd,datediff(dd,0,logs.trandatetime),0)
and st.trandatetime<dateadd(dd,datediff(dd,0,logs.trandatetime)+1,0)
order by st.trandatetime desc
)endq
--trandesc,
--,*
--,tran_start.*
--,tran_end.*
*/

from translog logs
left join translog tran_start on tran_start.id_tran=(
select top 1 st.id_tran
from translog st
where st.tranuserID=logs.tranuserID
and st.trandatetime>dateadd(dd,datediff(dd,0,logs.trandatetime),0)
order by st.trandatetime
)
left join translog tran_end on tran_end.id_tran=(
select top 1 st.id_tran
from translog st
where st.tranuserID=logs.tranuserID
and st.trandatetime>dateadd(dd,datediff(dd,0,logs.trandatetime),0)
and st.trandatetime<dateadd(dd,datediff(dd,0,logs.trandatetime)+1,0)
order by st.trandatetime desc
)
where logs.trancode in( 64,65)
and logs.trandatetime> '2015-10-10 00:00:00'
order by logs.tranuser
