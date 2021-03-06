declare @MOTCONSU_ID int
,@PATIENTS_ID int
,@MEDECINS_ID int
,@MODELS_ID int
,@FM_DEP_ID int
,@MEDDEP_ID int
,@DATE_CONSULTATION datetime


select
@PATIENTS_ID=160918	-- Пациент
,@MEDECINS_ID=700	-- Врач Лаборатория
,@MODELS_ID=159		-- Тип записи Лаборатория результаты 
,@FM_DEP_ID=15		-- Отделение Лаборатория
,@MEDDEP_ID=746		-- Отделение, привязанное к пользователю
,@DATE_CONSULTATION=GetDate()


exec up_get_id  @KeyName = 'MOTCONSU', @Shift = 1, @ID = @MOTCONSU_ID output
select @MOTCONSU_ID Result

BEGIN TRAN 

insert into MOTCONSU
(MOTCONSU_ID,PATIENTS_ID
,DATE_CONSULTATION
,MODIFY_DATE_TIME,CREATE_DATE_TIME
,MODELS_ID,FM_DEP_ID
,MEDECINS_ID,MEDECINS_CREATE_ID
,MEDECINS_MODIFY_ID,KRN_CREATE_USER_ID
,MEDDEP_ID
,REC_STATUS,PUBLISHED,CHANGED)
values
(@MOTCONSU_ID,@PATIENTS_ID
,@DATE_CONSULTATION
,GetDate(),GetDate()
,@MODELS_ID,@FM_DEP_ID
,@MEDECINS_ID,@MEDECINS_ID
,@MEDECINS_ID,@MEDECINS_ID
,@MEDDEP_ID
,'W',0,0)

COMMIT TRAN 

