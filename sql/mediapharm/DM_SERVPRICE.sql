select 
fm_serv.code,
fm_serv.label,
ec_price.cod_oms,
DM_SERVPRICE.*
from DM_SERVPRICE
left join fm_serv on fm_serv.fm_serv_id=DM_SERVPRICE.fm_serv_id
left join ec_price on ec_price.cod_dms=fm_serv.code
--where DM_SERVPRICE.DM_SERVPRICE_ID = DM_SERVPRICE.DM_SERVPRICE_NORM_ID
--where DM_SERVPRICE.is_fact='n'
order by 
DM_SERVPRICE_ID,
code