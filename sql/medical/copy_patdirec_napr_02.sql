/* copy_patdirec_napr */
DECLARE @data_id int
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
	,@patients_id int
	,@date_consultation datetime
	 
 declare @ERRNO   int, @ERRMSG  varchar(255)

select @current_motconsu_id= 81596 /* :%AF_CURRENT_MOTCONSU  */
	,@current_user_id=	 787 	/* :%AF_CURRENT_MEDECIN */
	,@motconsu_old=81355
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

select @date_consultation=DATE_CONSULTATION
		,@patients_id=PATIENTS_ID
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

	exec RebuildPatdirecDirAnsws @patdirec_new, 0, NULL
------------------------------------------
FETCH NEXT FROM patdirec_cur INTO @patdirec_old
end
CLOSE patdirec_cur
DEALLOCATE patdirec_cur
----------------

select @data_id=DATA24_ID
from DATA_PRESCR_AND_RECOMMEND
where MOTCONSU_ID=@current_motconsu_id

if (@data_id is null)
begin
	exec up_get_id  @KeyName = 'DATA_PRESCR_AND_RECOMMEND', @Shift = 1, @ID = @data_id output
	insert into DATA_PRESCR_AND_RECOMMEND
	(DATA24_ID,PATIENTS_ID
	,DATE_CONSULTATION,MOTCONSU_ID
	,NAPRAVLENIE_NA_MEDIKO_SOC
	,DRUGIE_NAPRAVLENIQ
	)
	values
	(@data_id,@patients_id
	,@date_consultation,@current_motconsu_id
	,0,0
	)
	
	update MOTCONSU_XML set 
	FILLED_TABLES='{R}[T]DATA_PRESCR_AND_RECOMMEND;'
	where MOTCONSU_ID=@current_motconsu_id
end

update new set 
       new.[PITANIE_DIETA]		=old.[PITANIE_DIETA]
      ,new.[DIETIHESKIJ_STOL]	=old.[DIETIHESKIJ_STOL]
      ,new.[REGIM]				=old.[REGIM]
      ,new.[KONSUL_TACII]		=old.[KONSUL_TACII]
      ,new.[ANALIZ]				=old.[ANALIZ]
      ,new.[METOD_OBSLEDOVANIQ]	=old.[METOD_OBSLEDOVANIQ]
      ,new.[UL_TRAZVUKOV_E_ISSLEDOVAN]=old.[UL_TRAZVUKOV_E_ISSLEDOVAN]
      ,new.[MANIPULQCII]		=old.[MANIPULQCII]
      ,new.[KOMPLEKSNAYA_DIAGNOSTIKA]=old.[KOMPLEKSNAYA_DIAGNOSTIKA]
      ,new.[FIZIOTERAPIQ]		=old.[FIZIOTERAPIQ]
      ,new.[LUCHEVAYA_TERAPIYA]	=old.[LUCHEVAYA_TERAPIYA]
      ,new.[PROCEDUR]			=old.[PROCEDUR]
      ,new.[MASSAG]				=old.[MASSAG]
      ,new.[LFK_I_KLIMATOTERAPIYA]=old.[LFK_I_KLIMATOTERAPIYA]
      ,new.[SESTRINSKIY_UHOD]	=old.[SESTRINSKIY_UHOD]
      ,new.[REABILITACIYA_I_OBUCHENIE]=old.[REABILITACIYA_I_OBUCHENIE]
      ,new.[VAKCINACIYA]		=old.[VAKCINACIYA]
      ,new.[STACIONAR]=old.[STACIONAR]
      ,new.[STOMATOLOGIQ]		=old.[STOMATOLOGIQ]
      ,new.[KOSMETOLOGIQ]		=old.[KOSMETOLOGIQ]
      ,new.[PROCHEE]			=old.[PROCHEE]
      ,new.[MANIPULQCII1]		=old.[MANIPULQCII1]
      ,new.[REKOMENDACII]		=old.[REKOMENDACII]
      ,new.[MEDIKAMENTOZNAQ_TERAPIQ]=old.[MEDIKAMENTOZNAQ_TERAPIQ]
      ,new.[PLAN_LEHENIQ]		=old.[PLAN_LEHENIQ]
      ,new.[NAZNAHENIQ_I_REKOMENDACII]=old.[NAZNAHENIQ_I_REKOMENDACII]
      ,new.[REZUL_TAT_LEHENIQ]	=old.[REZUL_TAT_LEHENIQ]
  FROM DATA_PRESCR_AND_RECOMMEND old,DATA_PRESCR_AND_RECOMMEND new
  where old.MOTCONSU_ID=@motconsu_old and
  new.MOTCONSU_ID=@current_motconsu_id and
  new.PATIENTS_ID=@patients_id and
  old.PATIENTS_ID=@patients_id
  

end --if(@ERRNO>0)