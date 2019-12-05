/*
select
count(DM_SERV_MEDS.DM_SERV_MEDS_ID)
--, DM_SERV_MEDS.COST_GROUP
 ,fm_serv.CODE
--update DM_SERV_MEDS set IS_ACTIVE=1
from DM_SERV_MEDS
join DM_SERVPRICE on DM_SERV_MEDS.DM_SERVPRICE_ID=DM_SERVPRICE.DM_SERVPRICE_ID
join fm_serv on FM_SERV.FM_SERV_ID=DM_SERVPRICE.FM_SERV_ID
where DM_SERVPRICE.is_fact='n'
group by 
DM_SERV_MEDS.COST_GROUP
 ,fm_serv.CODE
having count(DM_SERV_MEDS.DM_SERV_MEDS_ID)>1
order by count(DM_SERV_MEDS.DM_SERV_MEDS_ID) desc ,fm_serv.CODE


--update DM_SERV_MEDS set COST_GROUP=
/*
select
ct.DM_SERV_MEDS_ID
 ,ct.COST_GROUP
 ,ct.code
 ,ord
 */
 /*
 update DM_SERV_MEDS set COST_GROUP=ct.ord
 from DM_SERV_MEDS
 join  
(select
DM_SERV_MEDS.DM_SERV_MEDS_ID,
 DM_SERV_MEDS.COST_GROUP
 ,fm_serv.CODE
,row_number() over(partition BY fm_serv.code order by fm_serv.code) ord
from DM_SERV_MEDS
join DM_SERVPRICE on DM_SERV_MEDS.DM_SERVPRICE_ID=DM_SERVPRICE.DM_SERVPRICE_ID
join fm_serv on FM_SERV.FM_SERV_ID=DM_SERVPRICE.FM_SERV_ID
where DM_SERVPRICE.is_fact='n'
and fm_serv.code in
--order by fm_serv.CODE,DM_SERV_MEDS.COST_GROUP
(
select
--count(DM_SERV_MEDS.DM_SERV_MEDS_ID)
--, DM_SERV_MEDS.COST_GROUP
 fm_serv.CODE
--update DM_SERV_MEDS set IS_ACTIVE=1
from DM_SERV_MEDS
join DM_SERVPRICE on DM_SERV_MEDS.DM_SERVPRICE_ID=DM_SERVPRICE.DM_SERVPRICE_ID
join fm_serv on FM_SERV.FM_SERV_ID=DM_SERVPRICE.FM_SERV_ID
where DM_SERVPRICE.is_fact='n'
group by 
DM_SERV_MEDS.COST_GROUP
 ,fm_serv.CODE
having count(DM_SERV_MEDS.DM_SERV_MEDS_ID)>1
--order by count(DM_SERV_MEDS.DM_SERV_MEDS_ID) desc ,fm_serv.CODE

)
)as ct
on ct.DM_SERV_MEDS_ID=DM_SERV_MEDS.DM_SERV_MEDS_ID
--order by ct.CODE
*/