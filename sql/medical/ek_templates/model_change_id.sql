USE [medialog]
GO

declare @new int
		,@old int
select @new=586
,@old=796


update CP_PLAN 
set ACTIVATE_MODELS_ID=@new
where ACTIVATE_MODELS_ID=@old

update ED_EXAM_SERV 
set MODELS_ID=@new
where MODELS_ID=@old

update ED_MODELS_SPEC 
set MODELS_ID=@new
where MODELS_ID=@old

update GP_MODELS 
set MODELS_ID=@new
where MODELS_ID=@old

update MOTCONSU 
set MODELS_ID=@new
where MODELS_ID=@old

update VIP_GR_DIR_RULES 
set MODELS_ID=@new
where MODELS_ID=@old

update VIP_GROUPS
set MODELS_ID=@new
where MODELS_ID=@old

---------

update VIP_PAT_ACCESS
set MODELS_ID=@new
where MODELS_ID=@old

update MOTCONSU_EVENT_TYPES_DET
set MODELS_ID=@new
where MODELS_ID=@old

update PR_CONFIG_MODELS
set MODELS_ID=@new
 from PR_CONFIG_MODELS
where MODELS_ID=@old

update VIP_DENY_MODELS_DET
set MODELS_ID=@new 
 from VIP_DENY_MODELS_DET
where MODELS_ID=@old

update MEDMODEL
set MODELS_ID=@new 
 from MEDMODEL
where MODELS_ID=@old

update MEDMODEL_DENIED
set MODELS_ID=@new 
 from MEDMODEL_DENIED
where MODELS_ID=@old

update MODEL_TEMPLATES
set MODELS_ID=@new 
 from MODEL_TEMPLATES
where MODELS_ID=@old

update INFO_MODELS
set MODELS_ID=@new 
 from INFO_MODELS
where MODELS_ID=@old

update EXAMENS
set MODELS_ID=@new 
 from EXAMENS
where MODELS_ID=@old

update INFO_MODELS
set MODELS_ID=@new 
 from INFO_MODELS
where MODELS_ID=@old

update MEDDEP
set MODELS_ID=@new 
 from MEDDEP
where MODELS_ID=@old 

update PL_EXAM
set MODELS_ID=@new 
 from PL_EXAM
where MODELS_ID=@old

update APP_SOU
set APP_SOU.MODELS_ID = @new
where MODELS_ID=@old

