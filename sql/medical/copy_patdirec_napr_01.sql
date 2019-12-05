/* copy_patdirec_napr */
DECLARE @id int
	,@patdirec_new int
	,@patdirec_old int
	,@pat_dr_det_id int
	,@p_drugs_new int
	,@p_drugs_old int
	,@dir_serv_new int
	,@dir_serv_old int
	,@motconsu_old int
	,@current_motconsu_id int	
	,@current_user_id int
	,@date_consultation datetime
	,@date_old datetime
	,@days_delta int		/*кол-во дней между старой и новой записью в эмк*/
	 
 declare @ERRNO   int, @ERRMSG  varchar(255)


select @current_motconsu_id=/*46295*/ 80485
	,@current_user_id=/*787*/	 787 
	,@motconsu_old=78881
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

select @date_consultation=DATE_CONSULTATION
from MOTCONSU where MOTCONSU_ID=@current_motconsu_id

declare patdirec_cur CURSOR LOCAL FOR
	select patdirec.patdirec_id from 
	patdirec
	where motconsu_id=@motconsu_old
    order by patdirec.patdirec_id
    
OPEN patdirec_cur
FETCH NEXT FROM patdirec_cur INTO @patdirec_OLD
WHILE @@FETCH_STATUS=0
BEGIN
begin tran

exec up_get_id  @KeyName = 'PATDIREC', @Shift = 1, @ID = @patdirec_new output

insert into PATDIREC
(PATDIREC_ID
,DIR_STATE
,PATIENTS_ID
,MEDECINS_CREATOR_ID
,MOTCONSU_ID
,PL_EXAM_ID
,QUANTITY,BIO_TYPE
,[DESCRIPTION]
,COMMENTAIRE
,CITO
,FM_ORG_ID,FM_INTORG_ID
,STANDARTED
,CREATE_DATE_TIME,CANCELLED,BEGIN_DATE_TIME
,MANIPULATIVE,KEEP_INTAKE_TIME,PATDIREC_KIND,NEED_OPEN_EDITOR
)
select
@patdirec_new			as PATDIREC_ID
,0						as DIR_STATE
,PATIENTS_ID			as PATIENTS_ID
,@current_user_id		as MEDECINS_CREATOR_ID
,@current_motconsu_id	as MOTCONSU_ID
,PL_EXAM_ID				
,QUANTITY,BIO_TYPE
,[DESCRIPTION]
,COMMENTAIRE
,CITO
,FM_ORG_ID,FM_INTORG_ID
,STANDARTED
,GETDATE()				as CREATE_DATE_TIME
,0						as CANCELLED
,@date_consultation		as BEGIN_DATE_TIME
,MANIPULATIVE,KEEP_INTAKE_TIME,PATDIREC_KIND,NEED_OPEN_EDITOR
FROM PATDIREC where patdirec_id=@patdirec_OLD
 
commit tran
------------------------------------------
/* заполнение услуг */
declare dir_serv_cur CURSOR LOCAL FOR
select DIR_SERV_ID
from DIR_SERV
where PATDIREC_ID=@patdirec_old

OPEN dir_serv_cur
FETCH NEXT FROM dir_serv_cur INTO @dir_serv_old
WHILE @@FETCH_STATUS=0
BEGIN
------------------
exec up_get_id  @KeyName = 'DIR_SERV', @Shift = 1, @ID = @DIR_serv_new output

insert into DIR_SERV
(DIR_SERV_ID,PATDIREC_ID
,PATIENTS_ID
,FM_SERV_ID,CNT
,FREE_PAY
)
select
@dir_serv_new	as DIR_SERV_ID
,@patdirec_new	as PATDIREC_ID
,PATIENTS_ID
,FM_SERV_ID,CNT
,FREE_PAY
from DIR_SERV
where DIR_SERV_ID=@dir_serv_old
------------------------------------------
FETCH NEXT FROM dir_serv_cur INTO @dir_serv_old
end
CLOSE dir_serv_cur
DEALLOCATE dir_serv_cur
------------------------------------------
FETCH NEXT FROM patdirec_cur INTO @patdirec_old
end
CLOSE patdirec_cur
DEALLOCATE patdirec_cur
end


