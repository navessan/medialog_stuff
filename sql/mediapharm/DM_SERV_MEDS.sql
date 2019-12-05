select 
fm_serv.code,
fm_serv.label,
DM_SERVPRICE.IS_FACT,
DM_SERV_MEDS.*
from  DM_SERV_MEDS
join DM_SERVPRICE on DM_SERV_MEDS.DM_SERVPRICE_ID=DM_SERVPRICE.DM_SERVPRICE_ID
left join fm_serv on fm_serv.fm_serv_id=DM_SERVPRICE.fm_serv_id

--where DM_SERV_MEDS.DM_SERV_MEDS_ID = DM_SERV_MEDS.DM_SERV_MEDS_NORM_ID 
where DM_SERVPRICE.is_fact='n'

order by code