			/* уведомление врачу */
			declare @SMS_TEMPLATE_MEDIC varchar(4000)
					,@BODY varchar(4000)
					,@medic_phone varchar(20)
					,@notify_type varchar(64)
					,@PatientsID int
					,@DateNotify datetime
					,@REC_ID int
					,@mes_id int

			select @SMS_TEMPLATE_MEDIC='К вам %ExamTime% записан пациент'
				,@notify_type='PLANNING_MEDIC_NOTIFY'
				
DECLARE cur CURSOR 
   LOCAL           -- LOCAL or GLOBAL
   FORWARD_ONLY    -- FORWARD_ONLY or SCROLL
   STATIC          -- STATIC, KEYSET, DYNAMIC, or FAST_FORWARD
   READ_ONLY       -- READ_ONLY, SCROLL_LOCKS, or OPTIMISTIC
   TYPE_WARNING    -- Inform me of implicit conversions
FOR
-----------------------									
			select 
			PLANNING.PATIENTS_ID
			,TELEFON
			,DATEADD(MINUTE,-5,DATE_START)	as notify
			,replace(@SMS_TEMPLATE_MEDIC, '%ExamTime%', convert(varchar(15), DATE_START, 4) + ' в ' + convert(varchar(5), DATE_START, 108))
					+' '+PLANNING.NOM+' '+PLANNING.PRENOM+' '+PLANNING.PATRONYME 
					+isnull(' '+convert(varchar(15), NE_LE, 4)+'гр','')
					as body
			,PLANNING.PLANNING_ID	
			,REC_ID as mes_id
			from PLANNING 
			join PL_SUBJ  on PLANNING.PL_SUBJ_ID=PL_SUBJ.PL_SUBJ_ID
			join MEDECINS on MEDECINS.MEDECINS_ID=PL_SUBJ.MEDECINS_ID 
			left join PATIENTS on PATIENTS.PATIENTS_ID=PLANNING.PATIENTS_ID
			left join SMS_MESSAGES as s on s.REC_ID= PLANNING.PLANNING_ID and s.REC_TYPE=@notify_type
			where len(MEDECINS.TELEFON)>6 and
			 PLANNING.DATE_START > getdate() and
			isnull(PLANNING.STATUS,0)=0 and		--действующие записи
			isnull(PLANNING.CANCELLED,0)=0 
			--and	s.SMS_MESSAGES_ID is null
			--and PLANNING.PATIENTS_ID=21541
-----------------------
OPEN Cur;
FETCH NEXT FROM Cur into 
		@PatientsID
		,@medic_phone
		,@DateNotify
		,@BODY
		,@REC_ID
		,@mes_id;
WHILE @@FETCH_STATUS = 0
	BEGIN
	---------------------------------
	select @PatientsID,@medic_phone,@DateNotify,@BODY,@REC_ID,@mes_id

		if exists(select SMS_MESSAGES_ID 
					from SMS_MESSAGES where REC_ID=@REC_ID and REC_TYPE=@notify_type)
		begin
			update SMS_MESSAGES set
			PHONE = @medic_phone,
			PATIENTS_ID = @PatientsID,
			BODY = @BODY
			from SMS_MESSAGES
			where REC_ID=@REC_ID and
				REC_TYPE = @notify_type
		end
		else
		begin
			exec CreateSMS @PatientsID, @medic_phone, @DateNotify, @BODY, @REC_ID, @notify_type
		end
	---------------------------------
		FETCH NEXT FROM Cur into 
		@PatientsID
		,@medic_phone
		,@DateNotify
		,@BODY
		,@REC_ID
		,@mes_id;
	END;
CLOSE Cur;
DEALLOCATE Cur;

