/* patdirec_set_expired */
DECLARE @current_motconsu_id int
	,@medecins_id as int
	,@current_user_id int
	,@patients_id int
	,@date_consultation datetime
		
declare @ERRNO   int, @ERRMSG  varchar(255)

select
	 @current_motconsu_id=83836 /* :%AF_CURRENT_MOTCONSU */
	,@current_user_id= 787/* :%AF_CURRENT_MEDECIN */
 
select
	 @medecins_id=MEDECINS_ID
	,@patients_id=PATIENTS_ID
	,@date_consultation=DATE_CONSULTATION
 from MOTCONSU 
where MOTCONSU_ID=@current_motconsu_id

/*проверка прав текущего пользователя к врачу в талоне */
if(dbo.ek_motconsu_check_user_ACL (@current_motconsu_id, @medecins_id, @current_user_id)=0)
  raiserror 50002 'Нет прав на редактирование записи'
else
begin
	update DIR_ANSW set 
	ANSW_STATE=2
	,MOTCONSU_CANCEL_ID=@current_motconsu_id
	from DIR_ANSW
	INNER JOIN PATDIREC on PATDIREC.PATDIREC_ID=DIR_ANSW.PATDIREC_ID
	INNER JOIN PL_EXAM PL_EXAM ON PL_EXAM.PL_EXAM_ID = PATDIREC.PL_EXAM_ID 
	INNER JOIN PL_EX_GR PL_EX_GR ON PL_EX_GR.PL_EX_GR_ID = PL_EXAM.PL_EX_GR_ID 
	where 
	PATDIREC.PATIENTS_ID=@patients_id and
	PATDIREC.MOTCONSU_ID is not null and /* из ЭМК */
--	(PATDIREC.END_DATE_TIME is null or PATDIREC.END_DATE_TIME>@date_consultation) and 
	PATDIREC.DIR_STATE=1 and /*Статус Подтвержденное */
	PATDIREC.CANCELLED=0 and 
	PL_EX_GR.TYPE =0		/* направления */
 /* Отмененное */ 
	update PATDIREC set 
	 PATDIREC.DIR_STATUS_ID=5 /* Отменено с датой */
	,PATDIREC.END_DATE_TIME=coalesce(PATDIREC.END_DATE_TIME, @date_consultation)
	,DIR_STATE=3
	,MOTCONSU_CANCEL_ID=@current_motconsu_id
	,CANCELED_NOTE='stop by script'
	,CANCELLED=1
	from PATDIREC
	INNER JOIN PL_EXAM PL_EXAM ON PL_EXAM.PL_EXAM_ID = PATDIREC.PL_EXAM_ID 
	INNER JOIN PL_EX_GR PL_EX_GR ON PL_EX_GR.PL_EX_GR_ID = PL_EXAM.PL_EX_GR_ID 
	where 
	PATDIREC.PATIENTS_ID=@patients_id and
	PATDIREC.MOTCONSU_ID is not null and /* из ЭМК */
--	(PATDIREC.END_DATE_TIME is null or PATDIREC.END_DATE_TIME>@date_consultation) and 
	PATDIREC.DIR_STATE=1 and /*Статус Подтвержденное */
	PATDIREC.CANCELLED=0 and 
	PL_EX_GR.TYPE =0		/* направления */
end


