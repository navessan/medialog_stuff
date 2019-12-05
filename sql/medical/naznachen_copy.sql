/* НОВЫЙЙЙЙЙ   */

set nocount on

DECLARE @id int
	,@patdirec_new int
	,@patdirec_old int
	,@pat_dr_det_id int
	,@p_drugs_new int
	,@p_drugs_old int
	,@DIR_ANSW_new int
	,@DIR_ANSW_old int
	,@motconsu_old int
	,@current_motconsu_id int	
	,@current_user_id int
	,@date_consultation datetime
	,@date_old datetime
	,@days_delta int		/*кол-во дней между старой и новой записью в эмк*/
	 
 declare @ERRNO   int, @ERRMSG  varchar(255)


select @current_motconsu_id=46295	/* :%AF_CURRENT_MOTCONSU */
	,@current_user_id=787	 /* :%AF_CURRENT_MEDECIN */
	,@motconsu_old=46622	/* :@{R}[T]DATA_W716_COPY_PRESCRIPTION.KOPIRUEMOE_NAZNACHENIE */
	,@ERRNO=0
	,@date_consultation=null
 
if ( exists ( select patdirec_id  from patdirec where motconsu_id =@current_motconsu_id))
     select @ERRNO = 50001, @ERRMSG  ='Для данной записи уже были созданы назначения, удалите существующие, если они были созданы ошибочно'

if (@motconsu_old is null)
     select @ERRNO = 50001, @ERRMSG  ='Не выбрана исходная запись для копирования'

if(@ERRNO>0)
     raiserror @ERRNO @ERRMSG 
else
begin

/*
значение устанавливается выше
select @motconsu_id=KOPIRUEMOE_NAZNACHENIE 
from DATA_W716_COPY_PRESCRIPTION
where motconsu_id=@current_motconsu_id
*/

select @date_old=DATE_CONSULTATION
from MOTCONSU where MOTCONSU_ID=@motconsu_old

select @date_consultation=dateadd(dd,datediff(dd,0,motconsu.DATE_CONSULTATION), 0 )
,@days_delta=datediff(dd,@date_old,motconsu.DATE_CONSULTATION)
from MOTCONSU where MOTCONSU_ID=@current_motconsu_id

declare drug_kur CURSOR LOCAL FOR
   select patdirec.patdirec_id from 
    patdirec inner join patdirec_drugs on patdirec.patdirec_id=patdirec_drugs.patdirec_id where motconsu_id=@motconsu_old
    order by patdirec.patdirec_id
    
OPEN drug_kur
FETCH NEXT FROM drug_kur INTO @patdirec_OLD
WHILE @@FETCH_STATUS=0
BEGIN
begin tran

exec up_get_id  @KeyName = 'PATDIREC', @Shift = 1, @ID = @patdirec_new output
exec up_get_id  @KeyName = 'PATDIREC_DRUGS', @Shift = 1, @ID = @p_drugs_new output
exec up_get_id  @KeyName = 'PATDIREC_DRUGS_DET', @Shift = 1, @ID = @pat_dr_det_id output

insert into patdirec (patdirec_id
      ,[PATIENTS_ID]
      ,[MEDECINS_CREATOR_ID]
      ,motconsu_id
      ,[PLANNING_ID]
      ,[PL_EXAM_ID]
      ,[QUANTITY]
      ,[QUANTITY_DONE]
      ,[DESCRIPTION]
      ,[COMMENTAIRE]
      ,[CANCELLED]
      ,[BIO_CODE]
      ,[MEDECINS_BIO_ID]
      ,[DATE_BIO]
      ,[COMMENT_BIO]
      ,[MOTCONSU_CANCEL_ID]
      ,[FM_ORG_ID]
      ,[EXT_ORDER]
      ,[FM_INTORG_ID]
      ,[STANDARTED]
      ,[CANCELED_NOTE]
      ,[CITO]
      ,[DIR_STATUS_ID]
      ,[LAB_DESCRIPTION]
      ,[CREATE_DATE_TIME]
      ,[MODIFY_DATE_TIME]
      ,[MEDECINS_MODIFY_ID]
      ,[BIO_TYPE]
      ,[VIP_GROUPS_ID]
      ,[STATE]
      ,[MEDECINS_BIO_DEP_ID]
      ,[DIR_STATE]
      ,[MOTCONSU_APPROVE_ID]
      ,[BEGIN_DATE_TIME]
      ,[END_DATE_TIME]
      ,[TEMPLATE_XML]
      ,[QUANTITY_CANCEL]
      ,[MANIPULATIVE]
      ,[SUSPENDED]
      ,[NEED_OPEN_EDITOR]
      ,[KEEP_INTAKE_TIME]
      ,[THERAPY_CHECK_STATE]
      ,[PATDIREC_KIND])
    
SELECT @patdirec_new as patdirec_id
      ,[PATIENTS_ID]
      ,@current_user_id as user_id
      ,@current_motconsu_id as motconsu_id
      ,[PLANNING_ID]
      ,[PL_EXAM_ID]
      ,[QUANTITY]
      ,0		as [QUANTITY_DONE]
      ,[DESCRIPTION]
      ,[COMMENTAIRE]
      ,[CANCELLED]
      ,[BIO_CODE]
      ,[MEDECINS_BIO_ID]
      ,[DATE_BIO]
      ,[COMMENT_BIO]
      ,null as [MOTCONSU_CANCEL_ID]
      ,[FM_ORG_ID]
      ,[EXT_ORDER]
      ,[FM_INTORG_ID]
      ,[STANDARTED]
      ,[CANCELED_NOTE]
      ,[CITO]
      ,[DIR_STATUS_ID]
      ,[LAB_DESCRIPTION]
      ,GETDATE()		as [CREATE_DATE_TIME]
      ,GETDATE()		as [MODIFY_DATE_TIME]
      ,@current_user_id	as MEDECINS_MODIFY_ID
      ,[BIO_TYPE]
      ,[VIP_GROUPS_ID]
      ,[STATE]
      ,[MEDECINS_BIO_DEP_ID]
      ,1	as [DIR_STATE]
      ,null as [MOTCONSU_APPROVE_ID]
      ,@date_consultation+dateadd(hour,datepart(HOUR,[BEGIN_DATE_TIME]),0)+dateadd(minute,datepart(minute,[BEGIN_DATE_TIME]),0)
      ,@date_consultation+dateadd(hour,datepart(HOUR,[END_DATE_TIME]),0)+dateadd(minute,datepart(minute,[END_DATE_TIME]),0)
			+DATEADD(dd,datediff(dd,[BEGIN_DATE_TIME],[END_DATE_TIME]),0)
      ,[TEMPLATE_XML]
      ,[QUANTITY_CANCEL]
      ,[MANIPULATIVE]
      ,[SUSPENDED]
      ,[NEED_OPEN_EDITOR]
      ,[KEEP_INTAKE_TIME]
      ,[THERAPY_CHECK_STATE]
      ,[PATDIREC_KIND]
  FROM PATDIREC where patdirec_id=@patdirec_OLD
 
insert into patdirec_drugs ([PATDIREC_DRUGS_ID]
      ,[PATDIREC_ID]
      ,[DRUG_DESCR]
      ,[OWN_DRUGS]
      ,[TYPE_RECEPTION]
      ,[FOODLINK]
      ,[PR_INTAKE_METHODS_ID]
      ,[IS_MIXT]
      ,[INTAKE_SPEED]
      ,[INTAKE_SPEED_MEASURE_ID]
      ,[INTAKE_ZONE]
      ,[DM_MEASURE_ID]
      ,[ON_DEMAND]
      ,[IS_COMPLEX]
      ,[INTAKES_PER_DAY]
      ,[DOSE]
      ,[INTAKES_STR]
      ,[USE_WORKING_DAYS]
      ,[DEFAULT_LOTS_ID]
      ,[OLD_VERSION])
      
SELECT @p_drugs_new	as PATDIREC_DRUGS_ID
      ,@patdirec_new	as PATDIREC_ID
      ,[DRUG_DESCR]
      ,[OWN_DRUGS]
      ,[TYPE_RECEPTION]
      ,[FOODLINK]
      ,[PR_INTAKE_METHODS_ID]
      ,[IS_MIXT]
      ,[INTAKE_SPEED]
      ,[INTAKE_SPEED_MEASURE_ID]
      ,[INTAKE_ZONE]
      ,[DM_MEASURE_ID]
      ,[ON_DEMAND]
      ,[IS_COMPLEX]
      ,[INTAKES_PER_DAY]
      ,[DOSE]
      ,[INTAKES_STR]
      ,[USE_WORKING_DAYS]
      ,[DEFAULT_LOTS_ID]
      ,[OLD_VERSION]
  FROM PATDIREC_DRUGS where patdirec_id=@patdirec_old

select top 1 @p_drugs_old=patdirec_drugs_id from patdirec_drugs where patdirec_id=@patdirec_OLD  
  
  insert into patdirec_drugs_det (
  [PATDIREC_DRUGS_DET_ID]
      ,[PATDIREC_DRUGS_ID]
      ,[PR_DRUGS_ID]
      ,[DM_MEASURE_ID]
      ,[DOSE])
      
  SELECT @pat_dr_det_id	as [PATDIREC_DRUGS_DET_ID]
      ,@p_drugs_new	as [PATDIREC_DRUGS_ID]
      ,[PR_DRUGS_ID]
      ,[DM_MEASURE_ID]
      ,[DOSE]
  FROM patdirec_drugs_det where patdirec_drugs_id=@p_drugs_old

commit tran
------------------------------------------
/* заполнение плановых ответов */
declare dir_answ_cur CURSOR LOCAL FOR
select DIR_ANSW_ID
from DIR_ANSW
where PATDIREC_ID=@patdirec_old

select
	@DIR_ANSW_new	as DIR_ANSW_ID
	,@patdirec_new	as PATDIREC_ID
	,0		as ANSW_STATE
	,PLANE_DATE
	,DRUG_DOSE
	,WRITE_OFF,CHANGED,PACK_MEASURE_DOSE,CANCEL_PAY
from DIR_ANSW
where PATDIREC_ID=@patdirec_old

OPEN dir_answ_cur
FETCH NEXT FROM dir_answ_cur INTO @dir_answ_old
WHILE @@FETCH_STATUS=0
BEGIN

exec up_get_id  @KeyName = 'DIR_ANSW', @Shift = 1, @ID = @DIR_ANSW_new output

insert into DIR_ANSW
	(DIR_ANSW_ID
	,PATDIREC_ID
	,ANSW_STATE
	,PLANE_DATE
	,DRUG_DOSE
	,WRITE_OFF,CHANGED,PACK_MEASURE_DOSE,CANCEL_PAY)

select
	@DIR_ANSW_new	as DIR_ANSW_ID
	,@patdirec_new	as PATDIREC_ID
	,0		as ANSW_STATE
	,PLANE_DATE+dateadd(d,@days_delta,0)	as PLANE_DATE
	,DRUG_DOSE
	,WRITE_OFF,CHANGED,PACK_MEASURE_DOSE,CANCEL_PAY
from DIR_ANSW
where DIR_ANSW_ID=@DIR_ANSW_old
------------------------------------------
FETCH NEXT FROM dir_answ_cur INTO @dir_answ_old
end
CLOSE dir_answ_cur
DEALLOCATE dir_answ_cur
------------------------------------------
FETCH NEXT FROM drug_kur INTO @patdirec_old
end
CLOSE drug_kur
DEALLOCATE drug_kur
end


