DECLARE @PATIENT_ID as INT
	,@MEDECINS_ID as INT
	,@CURRENT_USER as int
	,@MOTCONSU_ID as int
	,@BILL_DATE as DATE
	,@FM_BILL_ID as int
	,@FM_BILLDET_ID as int
	,@PRICE as money
	
declare @ERRNO   int, @ERRMSG  varchar(255)


select @MEDECINS_ID=null /* :%AF_CURRENT_MOTCONSU_MEDECIN*/
	,@CURRENT_USER=787 /* :%AF_CURRENT_MEDECIN*/
	,@MOTCONSU_ID= null /* :%AF_CURRENT_MOTCONSU*/
	,@FM_BILL_ID=887707 /* :FM_BILL_ID */

select 
	@PATIENT_ID=FM_BILL.PATIENTS_ID
	,@MEDECINS_ID=FM_BILL.MEDECINS1_ID
	,@BILL_DATE=FM_BILL.BILL_DATE
from fm_bill
where FM_BILL_ID=@FM_BILL_ID

/*проверка прав текущего пользовател€ к врачу в талоне */
if(dbo.ek_motconsu_check_user_ACL (@MOTCONSU_ID, @MEDECINS_ID, @CURRENT_USER)=0)
  raiserror 50002 'Ќет прав на редактирование записи'


select @PRICE=ROUND(SUM(ROUND(DM_TRANSFERS.QUANTITY*DM_TRANSFERS.SALE_SUM*DM_TRANSFERS.MEASURE_FACTOR,2)),2)
from DM_DOC 
INNER JOIN DM_TRANSFERS DM_TRANSFERS ON DM_DOC.DM_DOC_ID = DM_TRANSFERS.DM_DOC_ID 
where 
DM_DOC_TYPE_ID=7 and 
ACCEPTED=1 and 
DM_DOC.PATIENTS_ID=@PATIENT_ID and 
dm_doc.MEDECINS_ID=@MEDECINS_ID and
datediff(d,0,INVOICE_DATE)=datediff(d,0,@BILL_DATE)

select @ERRNO = 0, @ERRMSG=''

if (isnull(@PRICE,0)=0)
     select @ERRNO = 50001, @ERRMSG  ='—умма медикаментов равна нулю.'

select @FM_BILLDET_ID=FM_BILLDET_ID
from FM_BILLDET
join FM_SERV on FM_BILLDET.FM_SERV_ID=FM_SERV.FM_SERV_ID
where
FM_BILLDET.FM_BILL_ID=@FM_BILL_ID and
FM_SERV.CODE='99955'

if (@FM_BILLDET_ID is null)
     select @ERRNO = 50001, @ERRMSG  =@ERRMSG+' ”слуга 99955 не внесена в талон.'


if(@ERRNO>0)
     raiserror @ERRNO @ERRMSG 
else
begin
select @PRICE
/*
update FM_BILLDET set 
PRICE=@PRICE
,TOTAL_PRICE=@PRICE
,PRICE_TO_PAY=@PRICE
,DATE_MODIFY=GETDATE()
,PRICE_FORCED=1
,PRICE_PAT=0
where FM_BILLDET_ID=@FM_BILLDET_ID


update FM_BILLDET_PAY set 
INVOICE_AMOUNT=@PRICE
,PRICE=@PRICE
where FM_BILLDET_ID=@FM_BILLDET_ID
/* раздельна€ оплата???? */

*/

end
