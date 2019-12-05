USE [medialog7]
GO
/****** Object:  StoredProcedure [dbo].[Alisa_new_motconsu_record]    Script Date: 04/16/2013 19:06:18 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER  PROCEDURE [dbo].[Alisa_new_motconsu_record](@PATIENTS_ID INT, @DATE_CONSULTATION datetime, @MOTCONSU_ID int out)
AS
BEGIN

if(@PATIENTS_ID is null or @DATE_CONSULTATION is null)
	begin
		raiserror ('Alisa_new_motconsu_record: Empty input parameters',-1,-1)
		return 1
	end


declare 
@MEDECINS_ID int
,@MODELS_ID int
,@FM_DEP_ID int
,@MEDDEP_ID int
--,@MOTCONSU_ID int
--,@PATIENTS_ID int
--,@DATE_CONSULTATION datetime


select
@MEDECINS_ID=700	-- Врач Лаборатория
,@MODELS_ID=159		-- Тип записи Лаборатория результаты 
,@FM_DEP_ID=15		-- Отделение Лаборатория
,@MEDDEP_ID=746		-- Отделение, привязанное к пользователю



exec up_get_id  @KeyName = 'MOTCONSU', @Shift = 1, @ID = @MOTCONSU_ID output
--select @MOTCONSU_ID Result

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

END
