
with data as(
SELECT 
fm_bill.bill_date
,count(distinct FM_BILL.PATIENTS_ID) pat_cnt, --кол-во пациентов
(count( distinct case when PATIENTS.POL=0 then FM_BILL.PATIENTS_ID end)) men,
(count(distinct case when PATIENTS.POL=1 then FM_BILL.PATIENTS_ID end)) women
,sum(FM_BILLDET.PRICE_TO_PAY) PRICE_TO_PAY
,sum(FM_BILLDET.PRICE_TO_PAY)/count(distinct FM_BILL.PATIENTS_ID) as sr_chek

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
fm_bill.bill_date
)
select
sum(pat_cnt) as pat_cnt
,sum(men) as men
,sum(women) as women
,sum(price_to_pay) as price_to_pay
,avg(sr_chek) as sr_chek
from data