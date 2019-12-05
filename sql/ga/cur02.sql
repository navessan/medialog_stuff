sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'Ole Automation Procedures', 1;  
GO  
RECONFIGURE;  
GO 
--------------------------

set nocount on

declare 
	@debug int
	,@TRAN_ID int
	,@TRAN_SUM money
	,@item varchar(64)
	,@find_pat int
	,@patientID int
	,@ua_client_id varchar(128)

select @debug=1

---------------
DECLARE cur CURSOR 
   LOCAL           -- LOCAL or GLOBAL
   FORWARD_ONLY    -- FORWARD_ONLY or SCROLL
   STATIC          -- STATIC, KEYSET, DYNAMIC, or FAST_FORWARD
   READ_ONLY       -- READ_ONLY, SCROLL_LOCKS, or OPTIMISTIC
   TYPE_WARNING    -- Inform me of implicit conversions
FOR
-----------------------
SELECT distinct
 FM_ACCOUNT_TRAN.FM_ACCOUNT_TRAN_ID
--,FM_ACCOUNT_TRAN.TRAN_DATE 
,-FM_ACCOUNT_TRAN.TRAN_SUM	as TRAN_SUM
--,FM_ACCOUNT_TRAN.TRAN_TYPE
,(case FM_ACCOUNT_TRAN.TRAN_TYPE 
	when 'Y' then 'Зачисление аванса'
	when 'P' then 'Оплата оказанных услуг'
	end) as item
--,TRAN_X.FM_CONTR_ID
,(case when TRAN_X.FM_CONTR_ID is not null then
(SELECT TOP 1 FM_CLINK_PATIENTS.PATIENTS_ID
FROM
 FM_CLINK_PATIENTS  WITH(NOLOCK)  
 JOIN FM_CLINK WITH(NOLOCK) ON FM_CLINK.FM_CLINK_ID = FM_CLINK_PATIENTS.FM_CLINK_ID 
 where FM_CLINK.FM_CONTR_ID =TRAN_X.FM_CONTR_ID
)end) find_pat		--пациент из прикрепления договора
,coalesce(FM_BILL.PATIENTS_ID,FM_INVOICE.PATIENTS_ID,FM_ORG.PATIENTS_ID) PATIENTS_ID	--пациент или плательщик
--,FM_INVOICE.FM_INVOICE_ID
FROM
 FM_INVOICE FM_INVOICE 
 LEFT OUTER JOIN FM_PAYMENTS FM_PAYMENTS ON FM_INVOICE.FM_INVOICE_ID = FM_PAYMENTS.FM_INVOICE_ID 
 JOIN FM_BILLDET_PAY FM_BILLDET_PAY WITH(NOLOCK)  ON FM_BILLDET_PAY.FM_BILLDET_PAY_ID = FM_PAYMENTS.FM_BILLDET_PAY_ID 
 JOIN FM_BILLDET FM_BILLDET WITH(NOLOCK)  ON FM_BILLDET.FM_BILLDET_ID = FM_BILLDET_PAY.FM_BILLDET_ID 
 JOIN FM_BILL FM_BILL WITH(NOLOCK)  ON FM_BILL.FM_BILL_ID = FM_BILLDET.FM_BILL_ID 
 LEFT OUTER JOIN FM_ACCOUNT_TRAN FM_ACCOUNT_TRAN ON FM_ACCOUNT_TRAN.FM_ACCOUNT_TRAN_ID = FM_PAYMENTS.FM_ACCOUNT_TRAN_ID 
 LEFT OUTER JOIN FM_ACCOUNT_TRAN TRAN_X ON FM_ACCOUNT_TRAN.FM_MAIN_TRAN_ID = TRAN_X.FM_ACCOUNT_TRAN_ID 
 LEFT OUTER JOIN FM_ORG FM_ORG ON FM_ORG.FM_ORG_ID = FM_INVOICE.FM_ORG_ID 
 left join [US_WEB_GA] ga on ga.REC_ID=FM_ACCOUNT_TRAN.FM_ACCOUNT_TRAN_ID
WHERE
 FM_ACCOUNT_TRAN.TRAN_TYPE in ('Y','P')  /* "Зачисление аванса","Оплата оказанных услуг" */
 and TRAN_X.FM_TRAN_CREDIT_ID is null /* без переводов с других ЛС*/
 and ga.REC_ID is null /* транзакция не выгружена */
 AND datediff(day,FM_ACCOUNT_TRAN.TRAN_DATE,GETDATE())<2
/*LookupKeys=X,Y,Z,A,B,P,U,I,O,Q,R,S,T,J,K,W,D,N,F
LookupValues=
X - "Внесение аванса",
Y - "Зачисление аванса",
Z - "Списание аванса",
A - "Внесение суммы на ЛС",
B - "Возврат суммы",
P - "Оплата оказанных услуг",
U - "Отмена оплаты услуг",
I - "Перевод  с другого ЛС",
O - "Перевод на другой ЛС",
J - "Оплата услуг с использованием аванса",
K - "Отмена оплаты услуг с использованием аванса",
W - "Возврат аванса",
D - "Кредиторская задолженность",
N - "Списание кредиторской задолженности",
F - "Возврат суммы для зачисления аванса"*/
-------------------------

--header
select 	'TRAN_ID'
	,'TRAN_SUM'
	,'item'
	,'find_pat'
	,'patientID'
	,'ua_client_id'
OPEN Cur;
FETCH NEXT FROM Cur into 	@TRAN_ID
	,@TRAN_SUM
	,@item
	,@find_pat
	,@patientID;
WHILE @@FETCH_STATUS = 0
	BEGIN
	---------------------------------
	--если нет пациента-плательщика, берем id из прикрепления
	if(@patientID is null)
		select @patientID=@find_pat

	--ищем ид пациента из звонков
	set @ua_client_id=null

	select top 1 
	@ua_client_id=cast(ua_client_id as varchar(128))
	from CALLS
	join US_WEB_COMAGIC_CALLS web_calls on web_calls.MEDIALOG_CALL_ID=CALLS.CALLS_ID
	where 
	CALLS.PATIENTS_ID=@patientID and
	web_calls.gclid is not null
	order by CALLS.CALLS_ID desc


	select 	@TRAN_ID
	,@TRAN_SUM
	,@item
	,@find_pat
	,@patientID
	,@ua_client_id

	if(@patientID is not null or @ua_client_id is not null)
	begin
		exec [dbo].[US_WEB_MEDIALOG_SEND_GA]  
			@TRAN_ID
			,@TRAN_SUM
			,@item
			,@patientID
			,@ua_client_id
			,@debug
	end
	---------------------------------
		FETCH NEXT FROM Cur into 	@TRAN_ID
	,@TRAN_SUM
	,@item
	,@find_pat
	,@patientID;
	END;
CLOSE Cur;
DEALLOCATE Cur;

-----------------------
GO  
sp_configure 'Ole Automation Procedures', 0;  
GO  
RECONFIGURE;