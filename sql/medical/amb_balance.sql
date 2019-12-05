-- network protocol: TCP/IP
set quoted_identifier off
set arithabort off
set numeric_roundabort off
set ansi_warnings off
set ansi_padding off
set ansi_nulls off
set concat_null_yields_null off
set cursor_close_on_commit off
set implicit_transactions off
set language us_english
set dateformat mdy
set datefirst 7
set transaction isolation level serializable 



declare @Contr table (ID int null)
insert into @Contr (id)
select contr.FM_ORG1_ID
	from FM_CONTR contr
	join FM_CLINK cl on cl.FM_CONTR_ID=contr.FM_CONTR_ID 
	join FM_CLINK_PATIENTS cp on cp.FM_CLINK_ID=cl.FM_CLINK_ID 
	where cp.PATIENTS_ID= 8864
	and isnull(contr.DEPOSIT,0)=0;



select sum(pay_sum) as on_account
,null as to_pay
,FM_ORG_ID
 from 
 (
SELECT
   FM_ACCOUNT_TRAN.TRAN_SUM,
  ((FM_ACCOUNT_TRAN.TRAN_SUM + Coalesce(Sum(FM_ACCOUNT_TRAN_1.TRAN_SUM),0))) PAY_SUM
  ,FM_ACCOUNT.FM_ORG_ID
FROM
 FM_ACCOUNT_TRAN FM_ACCOUNT_TRAN 
 LEFT OUTER LOOP JOIN FM_ACCOUNT_TRAN FM_ACCOUNT_TRAN_1 ON (FM_ACCOUNT_TRAN_1.FM_MAIN_TRAN_ID = FM_ACCOUNT_TRAN.FM_ACCOUNT_TRAN_ID)
 INNER LOOP JOIN FM_ACCOUNT FM_ACCOUNT ON FM_ACCOUNT.FM_ACCOUNT_ID = FM_ACCOUNT_TRAN.FM_ACCOUNT_ID 
WHERE
FM_ACCOUNT_TRAN.FM_MAIN_TRAN_ID is null 
and isnull(FM_ACCOUNT_TRAN.WRITTEN_OFF,0) = 0 
and FM_ACCOUNT_TRAN.FM_CONTR_ID is null 
and FM_ACCOUNT.FM_ORG_ID in (select id from @Contr)
GROUP BY
 FM_ACCOUNT_TRAN.FM_ACCOUNT_TRAN_ID,FM_ACCOUNT_TRAN.TRAN_SUM
,FM_ACCOUNT.FM_ACCOUNT_ID,FM_ACCOUNT.FM_ORG_ID
)
as tranz
group by FM_ORG_ID
-------------
--union all
----
/*
select null as on_account, SUM(FM_BILLDET_PAY_sub.PRICE) as to_pay,FM_BILLDET_PAY_sub.FM_ORG_ID
,sum(FM_BILLDET_sub.PRICE_TO_PAY)-(Cast(Coalesce(Sum(FM_PAYMENTS_sub.TRAN_AMOUNT - Coalesce(FM_PAYMENTS_sub.TAXE_AMOUNT,0)),0) as Float))
 FROM
 FM_BILLDET FM_BILLDET_sub
 LEFT OUTER JOIN FM_CLINK FM_CLINK_sub ON FM_CLINK_sub.FM_CLINK_ID =FM_BILLDET_sub.FM_CLINK_ID 
 JOIN FM_CONTR FM_CONTR_sub ON FM_CONTR_sub.FM_CONTR_ID = FM_CLINK_sub.FM_CONTR_ID
 LEFT OUTER JOIN FM_SERV FM_SERV_sub ON FM_SERV_sub.FM_SERV_ID = FM_BILLDET_sub.FM_SERV_ID 
 LEFT OUTER JOIN FM_BILLDET_PAY FM_BILLDET_PAY_sub ON FM_BILLDET_sub.FM_BILLDET_ID = FM_BILLDET_PAY_sub.FM_BILLDET_ID 
 LEFT OUTER JOIN FM_INVOICE FM_INVOICE_sub ON FM_INVOICE_sub.FM_INVOICE_ID = FM_BILLDET_PAY_sub.FM_INVOICE_ID 
 LEFT OUTER JOIN FM_PAYMENTS FM_PAYMENTS_sub ON FM_BILLDET_PAY_sub.FM_BILLDET_PAY_ID = FM_PAYMENTS_sub.FM_BILLDET_PAY_ID 
 LEFT OUTER JOIN FM_ACCOUNT_TRAN FM_ACCOUNT_TRAN_sub ON FM_ACCOUNT_TRAN_sub.FM_ACCOUNT_TRAN_ID = FM_PAYMENTS_sub.FM_ACCOUNT_TRAN_ID 
 where 
 FM_BILLDET_PAY_sub.FM_ORG_ID is not null and 
 FM_SERV_sub.SERV_TYPE <> 'Z' and 
 FM_BILLDET_PAY_sub.CANCEL <> 1 and 
 FM_ACCOUNT_TRAN_sub.FM_ACCOUNT_TRAN_ID is null and
 FM_CONTR_sub.FM_ORG1_ID in (select id from @Contr)
group by FM_BILLDET_PAY_sub.FM_ORG_ID
-----
order by FM_ORG_ID
*/
select null as on_account
,sum(FM_BILLDET_sub.PRICE_TO_PAY)-(Cast(Coalesce(Sum(FM_PAYMENTS_sub.TRAN_AMOUNT - Coalesce(FM_PAYMENTS_sub.TAXE_AMOUNT,0)),0) as Float)) as to_pay
,FM_BILLDET_PAY_sub.FM_ORG_ID,FM_ORG_sub.LABEL
 FROM
 FM_BILLDET FM_BILLDET_sub
 LEFT OUTER JOIN FM_CLINK FM_CLINK_sub ON FM_CLINK_sub.FM_CLINK_ID =FM_BILLDET_sub.FM_CLINK_ID 
  JOIN FM_CONTR FM_CONTR_sub ON FM_CONTR_sub.FM_CONTR_ID = FM_CLINK_sub.FM_CONTR_ID
 LEFT OUTER JOIN FM_SERV FM_SERV_sub ON FM_SERV_sub.FM_SERV_ID = FM_BILLDET_sub.FM_SERV_ID 
 LEFT OUTER JOIN FM_BILLDET_PAY FM_BILLDET_PAY_sub ON FM_BILLDET_sub.FM_BILLDET_ID = FM_BILLDET_PAY_sub.FM_BILLDET_ID 
 LEFT OUTER JOIN FM_INVOICE FM_INVOICE_sub ON FM_INVOICE_sub.FM_INVOICE_ID = FM_BILLDET_PAY_sub.FM_INVOICE_ID 
 LEFT OUTER JOIN FM_PAYMENTS FM_PAYMENTS_sub ON FM_BILLDET_PAY_sub.FM_BILLDET_PAY_ID = FM_PAYMENTS_sub.FM_BILLDET_PAY_ID 
 join FM_ORG FM_ORG_sub on FM_BILLDET_PAY_sub.FM_ORG_ID=FM_ORG_sub.FM_ORG_ID
 where 
 FM_SERV_sub.SERV_TYPE <> 'Z' and 
 isnull(FM_CONTR_sub.DEPOSIT,0)=0 and
 isnull(FM_BILLDET_PAY_sub.CANCEL,0)=0 and 
 --isnull(FM_PAYMENTS_sub.WODOLG, 0)=0 and
 FM_BILLDET_PAY_sub.FM_ORG_ID in (select id from @Contr)
group by FM_BILLDET_PAY_sub.FM_ORG_ID,FM_ORG_sub.LABEL
-----
order by FM_ORG_ID