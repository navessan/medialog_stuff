
with data as(
SELECT
month(fm_bill.bill_date) as m
,(case
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 0 and 18 then '18'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 19 and 24 then '19-24'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 25 and 34 then '25-34'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 35 and 44 then '35-44'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 45 and 54 then '45-54'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 55 and 100 then '55-'
	end) as ageg
,(case when PATIENTS.POL=0 then 'M' else '>|<' end) as pol
,count(distinct 
	convert(varchar(32),FM_BILL.PATIENTS_ID)+convert(varchar(32),FM_BILL.BILL_DATE)
	) cnt
,cast(count(distinct FM_BILL.BILL_DATE) as float) as sr

FROM
FM_BILLDET FM_BILLDET WITH(NOLOCK)  
LEFT OUTER JOIN FM_SERV FM_SERV WITH(NOLOCK)  ON FM_SERV.FM_SERV_ID = FM_BILLDET.FM_SERV_ID 
JOIN FM_BILL FM_BILL WITH(NOLOCK)  ON FM_BILL.FM_BILL_ID = FM_BILLDET.FM_BILL_ID 
JOIN FM_CLINK FM_CLINK WITH(NOLOCK)  ON FM_CLINK.FM_CLINK_ID = FM_BILLDET.FM_CLINK_ID
JOIN FM_CONTR FM_CONTR WITH(NOLOCK)  ON FM_CONTR.FM_CONTR_ID = FM_CLINK.FM_CONTR_ID  
left JOIN PATIENTS PATIENTS WITH(NOLOCK)  ON PATIENTS.PATIENTS_ID = FM_BILL.PATIENTS_ID 
WHERE
 FM_BILL.BILL_DATE >= {ts '2019-01-01 00:00:00.000'}
  AND FM_BILL.BILL_DATE < {ts '2020-01-01 00:00:00.000'}
 AND FM_CONTR.CODE like '999%'
and FM_CONTR.FM_CONTR_id not in(10216)--пу 0
group by 
month(fm_bill.bill_date)
,FM_BILL.PATIENTS_ID
,(case
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 0 and 18 then '18'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 19 and 24 then '19-24'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 25 and 34 then '25-34'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 35 and 44 then '35-44'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 45 and 54 then '45-54'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 55 and 100 then '55-'
	end)
,(case when PATIENTS.POL=0 then 'M' else '>|<' end)
--having count(distinct FM_BILL.BILL_DATE)>1
)
------------
select
ageg
,pol
,sum(cnt) as posecheniy
,avg(sr) as sr_posech_month
from data
group by 
ageg
,pol