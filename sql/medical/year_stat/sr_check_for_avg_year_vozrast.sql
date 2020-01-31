
with data as(
SELECT 
fm_bill.bill_date
,(case
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 0 and 18 then '18'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 19 and 24 then '19-24'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 25 and 34 then '25-34'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 35 and 44 then '35-44'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 45 and 54 then '45-54'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 55 and 100 then '55-'
	end) as ageg
,count(distinct FM_BILL.PATIENTS_ID) pat_cnt, --���-�� ���������
(count( distinct case when PATIENTS.POL=0 then FM_BILL.PATIENTS_ID end)) men,
(count(distinct case when PATIENTS.POL=1 then FM_BILL.PATIENTS_ID end)) women
,sum(FM_BILLDET.PRICE_TO_PAY) PRICE_TO_PAY
,sum(FM_BILLDET.PRICE_TO_PAY)/count(distinct FM_BILL.PATIENTS_ID) as sr_chek
,sum(FM_BILLDET.cnt)/count(distinct FM_BILL.PATIENTS_ID) as sr_uslug
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
and FM_CONTR.FM_CONTR_id not in(10216)--�� 0
group by 
fm_bill.bill_date
,(case
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 0 and 18 then '18'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 19 and 24 then '19-24'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 25 and 34 then '25-34'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 35 and 44 then '35-44'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 45 and 54 then '45-54'
	when (YEAR(FM_BILL.BILL_DATE - PATIENTS.NE_LE)-1900) between 55 and 100 then '55-'
	end)
)
select
ageg
,sum(pat_cnt) as pat_cnt
,sum(men) as men
,sum(women) as women
,sum(price_to_pay) as price_to_pay
,avg(sr_chek) as sr_chek
,avg(sr_uslug) as sr_uslug
from data
group by ageg