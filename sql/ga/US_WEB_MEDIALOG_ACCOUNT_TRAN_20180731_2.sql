USE [med_euroonco_new]
GO
/****** Object:  StoredProcedure [dbo].[US_WEB_MEDIALOG_ACCOUNT_TRAN]    Script Date: 31.07.2018 19:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[US_WEB_MEDIALOG_ACCOUNT_TRAN]
as

set nocount on

declare 
	@debug int
	,@P1 int
	,@TRAN_ID int
	,@TRAN_DATE datetime
	,@TRAN_SUM money
	,@item varchar(64)
	,@FM_CONTR_ID int
	,@find_pat int
	,@patientID int
	,@cid varchar(128)
	,@cid_src varchar(128)
	,@add_params varchar(256)
	,@povtorny int

declare @res table(TRAN_ID int
				,TRAN_DATE datetime
				,TRAN_SUM money
				,item varchar(64)
				,FM_CONTR_ID int
				,find_pat int
				,patientID int
				,cid varchar(128)
				,cid_src varchar(128)
				,povtorny int)

select @debug=0

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
,FM_ACCOUNT_TRAN.TRAN_DATE 
,-FM_ACCOUNT_TRAN.TRAN_SUM	as TRAN_SUM
--,FM_ACCOUNT_TRAN.TRAN_TYPE
,(case FM_ACCOUNT_TRAN.TRAN_TYPE 
	when 'Y' then 'Зачисление аванса'
	when 'P' then 'Оплата оказанных услуг'
	end) as item
,TRAN_X.FM_CONTR_ID
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
 AND datediff(HOUR,FM_ACCOUNT_TRAN.TRAN_DATE,GETDATE())<12
 order by FM_ACCOUNT_TRAN_ID
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
/*
select 	'TRAN_ID'
	,'TRAN_SUM'
	,'item'
	,'find_pat'
	,'patientID'
	,'ua_client_id'
*/

OPEN Cur;
FETCH NEXT FROM Cur into 	@TRAN_ID
	,@TRAN_DATE
	,@TRAN_SUM
	,@item
	,@FM_CONTR_ID
	,@find_pat
	,@patientID;
WHILE @@FETCH_STATUS = 0
	BEGIN
	---------------------------------
	--если нет пациента-плательщика, берем id из прикрепления
	if(@patientID is null)
		select @patientID=@find_pat

----------------------------
	select @cid=null
			,@cid_src=null
			,@add_params=null
			,@povtorny=null
----------------------------
/* определяем повторность пациента */
if(@FM_CONTR_ID is not null)
begin
	/* первичный договор*/
	if not exists(
	select FM_CONTR_ID
	from FM_CONTR
	where FM_CONTR_ID=@FM_CONTR_ID
	and CONTRACTNUMBER like '%/1')
		select @povtorny=1
			,@cid_src='povtorny'
end
else
begin
	/*ищем старые услуги пациента */
	if exists(
	select FM_BILL_ID
	from fm_bill
	where PATIENTS_id=@patientID
	and datediff(d,BILL_DATE,GETDATE())>0)
		select @povtorny=1
			,@cid_src='povtorny'
end
----------------------------
if(@cid_src is null)
begin
	--ищем ид пациента из привязанных ранее ID
	select top 1 
	@cid=cid
	from US_WEB_GA
	where 
	PAT_ID=@patientID and
	len(cid)>0
	order by US_WEB_GA_ID

	if(len(@cid)>0)
		select @cid_src='saved before'
end
----------------------------
if(@cid_src is null)
begin
	--ищем ид пациента из звонков, у которых проставлена прямая связь с пациентом
	select top 1 
	@cid=ua_client_id
	from CALLS
	join US_WEB_COMAGIC_CALLS web_calls on web_calls.MEDIALOG_CALL_ID=CALLS.CALLS_ID
	where 
	CALLS.PATIENTS_ID=@patientID and
	web_calls.ua_client_id is not null
	order by CALLS.CALLS_ID

	if(len(@cid)>0)
		select @cid_src='CALLS.CALLS_ID==US_WEB_COMAGIC_CALLS.MEDIALOG_CALL_ID'
end
----------------------------
if(@cid_src is null)
begin
	/* ищем по любому телефону пациента в комеджике */
	/* sql сойдет с ума */
	/* replace(dbo.PreparePhone(TELEFON,'7',''),'+','') */
	select top 1 
	@cid=ua_client_id
	from PATIENTS
	join US_WEB_COMAGIC_CALLS web_calls on (
			web_calls.numa=replace(dbo.PreparePhone(PATIENTS.MOBIL_TELEFON,'7',''),'+','') or
			web_calls.numa=replace(dbo.PreparePhone(PATIENTS.TEL,'7',''),'+','') or
			web_calls.numa=replace(dbo.PreparePhone(PATIENTS.RAB_TEL,'7',''),'+','') or
			web_calls.numa=replace(dbo.PreparePhone(PATIENTS.TELEFON_KONTAKTNOGO_LICA,'7',''),'+','')
			)
	where 
	PATIENTS_ID=@patientID and
	web_calls.ua_client_id is not null
	order by web_calls.US_WEB_COMAGIC_CALLS_ID

	if(len(@cid)>0)
		select @cid_src='PATIENTS.ANY_PHONE==US_WEB_COMAGIC_CALLS.numa'
end
----------------------------
if(@cid_src is null)
begin
	/* ищем по любому телефону пациента в обратных звонках с сайта */
	select top 1 
	@cid=cid
	from PATIENTS
	join us_web_site_callbacks web_calls on (
			web_calls.number=replace(dbo.PreparePhone(PATIENTS.MOBIL_TELEFON,'7',''),'+','') or
			web_calls.number=replace(dbo.PreparePhone(PATIENTS.TEL,'7',''),'+','') or
			web_calls.number=replace(dbo.PreparePhone(PATIENTS.RAB_TEL,'7',''),'+','') or
			web_calls.number=replace(dbo.PreparePhone(PATIENTS.TELEFON_KONTAKTNOGO_LICA,'7',''),'+','')
			)
	where 
	PATIENTS_ID=@patientID and
	web_calls.cid is not null
	order by web_calls.us_web_site_callbacks_id

	if(len(@cid)>0)
		select @cid_src='PATIENTS.ANY_PHONE==us_web_site_callbacks.number'
end
----------------------------
if(@cid_src is null)
begin
	/* ищем по телефонам представителей пациента в комеджике */

	select top 1 
	@cid=ua_client_id
	from DATA_W716_FOR_LEGAL_REP as rep
	join US_WEB_COMAGIC_CALLS web_calls on web_calls.numa=replace(dbo.PreparePhone(REP.TELEFON,'7',''),'+','')
	where 
	rep.PATIENTS_ID=@patientID and
	web_calls.ua_client_id is not null
	order by web_calls.US_WEB_COMAGIC_CALLS_ID

	if(len(@cid)>0)
		select @cid_src='FOR_LEGAL_REP.TELEFON==web_calls.numa'
end
----------------------------
if(@cid_src is null)
begin
	/* ищем по телефонам представителей пациента в обратных звонках с сайта */
	select top 1 
	@cid=cid
	from DATA_W716_FOR_LEGAL_REP as rep
	join us_web_site_callbacks web_calls on web_calls.number=replace(dbo.PreparePhone(REP.TELEFON,'7',''),'+','')
	where 
	PATIENTS_ID=@patientID and
	web_calls.cid is not null
	order by web_calls.us_web_site_callbacks_id

	if(len(@cid)>0)
		select @cid_src='FOR_LEGAL_REP.TELEFON==us_web_site_callbacks.number'
end
----------------------------
if(@cid_src is null)
begin
	--нигде нет ID, тогда берем KRN_GUID
	select top 1 
	@cid=KRN_GUID
	from PATIENTS
	where 
	PATIENTS_ID=@patientID
	
	if(len(@cid)>0)
		select @cid_src='PATIENTS.KRN_GUID'
end
----------------------------
if(@cid=(select top 1 KRN_GUID
	from PATIENTS 
	where PATIENTS_ID=@patientID)
	)
begin
	select @add_params='cs=%28direct%29&cm=MIS'
end
----------------------------
insert into @res
	select 	@TRAN_ID
	,@TRAN_DATE
	,@TRAN_SUM
	,@item
	,@FM_CONTR_ID
	,@find_pat
	,@patientID
	,@cid
	,@cid_src
	,@povtorny

	if(@patientID is not null and @cid is not null 
		and isnull(@povtorny,0)=0)
	begin
		exec [dbo].[US_WEB_MEDIALOG_SEND_GA]  
			@TRAN_ID
			,@TRAN_SUM
			,@item
			,@patientID
			,@cid
			,@cid_src
			,@add_params
			,@debug

	end
	if(@povtorny=1)
	begin
		/* создаем пустую транзакцию отправки */
		exec up_get_id  @KeyName = 'US_WEB_GA', @Shift = 1, @ID = @P1 output

		INSERT INTO [dbo].[US_WEB_GA] (
			US_WEB_GA_ID
		   ,[TYPE],[REC_ID]
           ,cid_src
           ,[PAT_ID])
		VALUES
           (@P1
		   ,'transaction',@TRAN_ID
           ,@cid_src
           ,@patientID)
	end
	---------------------------------
		FETCH NEXT FROM Cur into 	@TRAN_ID
	,@TRAN_DATE
	,@TRAN_SUM
	,@item
	,@FM_CONTR_ID
	,@find_pat
	,@patientID;
	END;
CLOSE Cur;
DEALLOCATE Cur;
-----------------------
select *
from @res

-----------------------
