
CREATE procedure [dbo].[US_CALC_FM_ORG_BALANCE](@PatientID int)

as
begin
/*
create table US_FM_ORG_BALANCE
(ID int identity(1,1)
,FM_ORG_ID int
,PAT_ID int
,AMB_ON_ACCOUNT money
,AMB_TO_PAY money
)

*/

declare 
	@fm_org_id int
	,@new_id int
	,@account_sum money
	,@to_pay money

--set @patientID=1

delete from US_FM_ORG_BALANCE
where PAT_ID=@PatientID

---------------
DECLARE cur CURSOR 
   LOCAL           -- LOCAL or GLOBAL
   FORWARD_ONLY    -- FORWARD_ONLY or SCROLL
   STATIC          -- STATIC, KEYSET, DYNAMIC, or FAST_FORWARD
   READ_ONLY       -- READ_ONLY, SCROLL_LOCKS, or OPTIMISTIC
   TYPE_WARNING    -- Inform me of implicit conversions
FOR
-----------------------
select distinct 
	contr.FM_ORG1_ID
	from FM_CONTR contr
	join FM_CLINK cl on cl.FM_CONTR_ID=contr.FM_CONTR_ID 
	join FM_CLINK_PATIENTS cp on cp.FM_CLINK_ID=cl.FM_CLINK_ID 
	where cp.PATIENTS_ID= @PatientID
	and isnull(contr.DEPOSIT,0)=0
	and contr.FM_ORG1_ID not in(492 /* לוהןנמדנאללû*/)
-------------------------
OPEN Cur;
FETCH NEXT FROM Cur into @fm_org_id;
WHILE @@FETCH_STATUS = 0
	BEGIN
	---------------------------------
	with tranz as
 ( /* accedit_trans modified */
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
and FM_ACCOUNT.FM_ORG_ID in (@fm_org_id)
GROUP BY
 FM_ACCOUNT_TRAN.FM_ACCOUNT_TRAN_ID,FM_ACCOUNT_TRAN.TRAN_SUM
,FM_ACCOUNT.FM_ACCOUNT_ID,FM_ACCOUNT.FM_ORG_ID
)
select @account_sum=sum(pay_sum)
 from tranz
 ------------------
 /* invpat_billdetpays modified */
 select
	@to_pay=SUM(PRICE_TO_PAY-TRAN_AMOUNT)
 from 
(
select 
FM_BILLDET_sub.PRICE_TO_PAY
,(Cast(Coalesce(Sum(FM_PAYMENTS_sub.TRAN_AMOUNT - Coalesce(FM_PAYMENTS_sub.TAXE_AMOUNT,0)),0) as Float)) as TRAN_AMOUNT
 FROM
 FM_BILLDET FM_BILLDET_sub
 LEFT OUTER JOIN FM_CLINK FM_CLINK_sub ON FM_CLINK_sub.FM_CLINK_ID =FM_BILLDET_sub.FM_CLINK_ID 
 LEFT OUTER JOIN FM_CONTR FM_CONTR_sub ON FM_CLINK_sub.FM_CONTR_ID =FM_CONTR_sub.FM_CONTR_ID 
 LEFT OUTER JOIN FM_SERV FM_SERV_sub ON FM_SERV_sub.FM_SERV_ID = FM_BILLDET_sub.FM_SERV_ID 
 LEFT OUTER JOIN FM_BILLDET_PAY FM_BILLDET_PAY_sub ON FM_BILLDET_sub.FM_BILLDET_ID = FM_BILLDET_PAY_sub.FM_BILLDET_ID 
 LEFT OUTER JOIN FM_INVOICE FM_INVOICE_sub ON FM_INVOICE_sub.FM_INVOICE_ID = FM_BILLDET_PAY_sub.FM_INVOICE_ID 
 LEFT OUTER JOIN FM_PAYMENTS FM_PAYMENTS_sub ON FM_BILLDET_PAY_sub.FM_BILLDET_PAY_ID = FM_PAYMENTS_sub.FM_BILLDET_PAY_ID 
 where 
 FM_SERV_sub.SERV_TYPE <> 'Z' and 
 isnull(FM_CONTR_sub.DEPOSIT,0)=0 and
 isnull(FM_BILLDET_PAY_sub.CANCEL,0)=0 and 
 FM_CONTR_sub.FM_ORG1_ID in ( @fm_org_id )
 group by FM_BILLDET_sub.FM_BILLDET_ID,PRICE_TO_PAY
)as billdet
 ------------------
	exec up_get_id  @KeyName = 'US_FM_ORG_BALANCE', @Shift = 1, @ID = @NEW_ID output

	insert into US_FM_ORG_BALANCE
	(ID, FM_ORG_ID,PAT_ID,AMB_ON_ACCOUNT,AMB_TO_PAY)
	values(
	@new_id
	,@fm_org_id,@PatientID
	,@account_sum,@to_pay)
	
	---------------------------------
		FETCH NEXT FROM Cur into @fm_org_id;
	END;
CLOSE Cur;
DEALLOCATE Cur;

--------
--select * from US_FM_ORG_BALANCE where pat_id=@patient_ID

end


GO


