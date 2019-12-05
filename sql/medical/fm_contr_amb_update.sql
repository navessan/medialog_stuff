/* fm_contr_amb_update */
DECLARE @PATIENT_ID as INT
	,@MEDECINS_ID as INT
	,@CURRENT_USER as int
	,@MOTCONSU_ID as int
	,@FM_CONTR_ID as int
	,@FM_CONTR_CODE as varchar(128)
	,@FM_CONTR_CODE_AN as varchar(128)
	,@CONTRACTNUMBER as varchar(128)
	,@date_start as date
	,@date_end as date
	,@pat_fio as varchar(128)
	,@pat_type as int

	
declare @ERRNO   int, @ERRMSG  varchar(255)

select @MEDECINS_ID=null 
	,@CURRENT_USER=1844 -- :%AF_CURRENT_MEDECIN
	,@FM_CONTR_ID=40 -- :contr
	,@PATIENT_ID=1 -- :%AF_CURRENT_PATIENT


select @FM_CONTR_CODE=CODE
	,@FM_CONTR_CODE_AN=CODE_AN
	,@CONTRACTNUMBER=CONTRACTNUMBER
	,@date_start=DATE_FROM
from FM_CONTR
where FM_CONTR_ID=@FM_CONTR_ID

/*проверка прав текущего пользовател€ к врачу в талоне */
/*
if(dbo.ek_motconsu_check_user_ACL (@MOTCONSU_ID, @MEDECINS_ID, @CURRENT_USER)=0)
  raiserror 50002 'Ќет прав на редактирование записи'
*/

if(@FM_CONTR_ID is null or ISNULL(@FM_CONTR_CODE,'')='' )
	select @ERRNO = 50001, @ERRMSG  =' Ќе выбран документ.'

if(ISNULL(@CONTRACTNUMBER,'')<>'' )
	select @ERRNO = 50001, @ERRMSG  =' Ќомер договора уже заполнен.'

/* проверка прав текущего пользовател€ к пользователю создавшему документ */
/*else if(isnull(dbo.ek_motconsu_check_user_ACL (null, @MEDECINS_ID, @CURRENT_USER),0)=0)
	select @ERRNO = 50001, @ERRMSG  ='Ќет прав на редактирование документа.'
*/

else if (@PATIENT_ID is null)
     select @ERRNO = 50001, @ERRMSG  ='Ќе выбран пациент.'
     
if(@ERRNO>0)
     raiserror @ERRNO @ERRMSG 
else
begin

--реквизиты пациента
select @pat_fio=isnull(NOM,'') +' '
	+SUBSTRING(isnull(PRENOM,''),1,1)+'. '
	+SUBSTRING(isnull(PATRONYME,''),1,1)+'.'
	,@pat_type=MEDECINS_ID	/*группа пациентов*/
from PATIENTS
where PATIENTS_ID=@PATIENT_ID

select 
/* берем из договора
@date_start=DATEADD(d,datediff(d,0,GETDATE()),0),
*/
@date_end=DATEADD(yy, DATEDIFF(yy,0,getdate()) + 1, -1) --AS EndOfYear

if(@pat_type=6)
begin
	/*VIP patient*/
	declare
		@Value integer,
		@Template varchar(50)

	exec dbo.up_get_counter_value  @KeyName = 'VIP_dogovor',  @Shift = 1,
	@Value = @Value output, @Template = @Template output

	select  @Value Value, @Template Template
	select @FM_CONTR_CODE=@Value

end

select @date_start,@date_end
,DATEDIFF(d,@date_start,@date_end)
,@FM_CONTR_CODE
,@pat_fio+' '+@FM_CONTR_CODE_AN+' є'+@FM_CONTR_CODE


update FM_CONTR set 
CODE=@FM_CONTR_CODE_AN+' є'+@FM_CONTR_CODE
,EXT_CODE=@pat_fio+' '+@FM_CONTR_CODE_AN+' є'+@FM_CONTR_CODE
,DATE_FROM=@date_start
,DATE_TO=@date_end
,DURATION=DATEDIFF(d,@date_start,@date_end)
,DURATION_MEASURE=0
,CONTRACTNUMBER=@FM_CONTR_CODE

where FM_CONTR_ID=@FM_CONTR_ID

end