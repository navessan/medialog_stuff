declare @P1 int
declare @P2 int
declare @user_id int			-- от чьего имени будет создано прикрепление
declare @fm_org_id int			-- организация
declare @orgs as varchar(32)	-- коды филиалов
declare @old_clink_id int		-- старые медпрограммы
declare @old_clink_id2 int
declare @new_clink_id int		-- новая медпрограмма
declare @date_begin as varchar(32)	-- с какой даты 
declare @date_create as datetime
declare @patient_id int

set @user_id=920

set @fm_org_id=3
set @orgs='05'
set @old_clink_id=2045 /* основной омс*/
set @old_clink_id2=4761 /* омс поликлиника*/
set @new_clink_id=13083 /* вне реализации */
set @date_begin='2012-01-01 00:00:00.000'
set @patient_id=603045

DECLARE cur CURSOR FOR
SELECT 
PATIENTS_ID
FROM
 FM_CLINK_PATIENTS
WHERE
 FM_CLINK_ID in (@old_clink_id,@old_clink_id2)
and (date_cancel is null or date_cancel> getdate())
and (date_to is null or date_to> getdate())
and FM_CLINK_PATIENTS.patients_id not in(
	SELECT PATIENTS_ID
	FROM FM_CLINK_PATIENTS
	WHERE FM_CLINK_ID = @new_clink_id
)
-------------------

OPEN Cur;
FETCH NEXT FROM Cur into @patient_id;
WHILE @@FETCH_STATUS = 0
   BEGIN
-----------------------------------------------------------------------------
exec up_get_id  @KeyName = 'FM_CLINK_PATIENTS', @Shift = 1, @ID = @P1 output
exec up_get_id  @KeyName = 'FM_CLINK_PATIENTS_ORG', @Shift = 1, @ID = @P2 output
select @P1 FM_CLINK_PATIENTS_ID, @P2 FM_CLINK_PATIENTS_ORG_ID
set @date_create=getdate()

BEGIN TRANSACTION;
insert into FM_CLINK_PATIENTS
(FM_CLINK_PATIENTS_ID,PATIENTS_ID,FM_CLINK_ID,DATE_FROM,MEDECINS_ID,CANCEL,MEDECINS_CREATE_ID,DATE_CREATE
,ORGS,FORCED_ORGS,FORCED_EXTORGS,CHANGED,DEF_CP)
values(@P1,@patient_id,@new_clink_id,@date_begin,@user_id,0,@user_id,@date_create,@orgs,0,0,0,0)

insert into FM_CLINK_PATIENTS_ORG
(FM_CLINK_PATIENTS_ORG_ID,FM_CLINK_PATIENTS_ID,FM_ORG_ID,KRN_CREATE_USER_ID,KRN_MODIFY_USER_ID)
values(@P2,@P1,@fm_org_id,@user_id,@user_id)
COMMIT TRANSACTION;
------------------------
      FETCH NEXT FROM Cur into @patient_id;
   END;
CLOSE Cur;
DEALLOCATE Cur;

