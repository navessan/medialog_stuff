
/****** Object:  Trigger [dbo].[PLANNING_AUTO_NOTIFY]    Script Date: 15.06.2017 18:18:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [dbo].[PLANNING_AUTO_NOTIFY] on [dbo].[PLANNING] for UPDATE, INSERT as
begin
  if UPDATE(DATE_CONS) OR UPDATE(HEURE) OR UPDATE(DUREE) OR UPDATE(PL_SUBJ_ID) OR UPDATE(DATE_START) OR
     UPDATE(PL_EXAM_ID) OR UPDATE(PATIENTS_ID) OR UPDATE(CANCELLED) OR UPDATE(STATUS) OR UPDATE(NOT_ACCEPTED)
  BEGIN
    declare @SEND_SMS_FOR_N_HOURS int, @NOT_SEND_SMS_FROM_TIME datetime, @NOT_SEND_SMS_TO_TIME datetime
		,@SMS_TEMPLATE varchar(4000)
		,@SMS_TEMPLATE_FIRST varchar(4000)
		,@SMS_TEMPLATE_LN varchar(4000)
    declare @ActionName varchar(20), @ExamTime varchar(20)
    declare @IsCanceled bit, @IsModified bit

    set @SEND_SMS_FOR_N_HOURS = null
    set @NOT_SEND_SMS_FROM_TIME = null
    set @NOT_SEND_SMS_TO_TIME = null
    set @SMS_TEMPLATE = null

    select @SEND_SMS_FOR_N_HOURS = SEND_SMS_FOR_N_HOURS,
           @NOT_SEND_SMS_FROM_TIME = convert(datetime, convert(varchar(8), NOT_SEND_SMS_FROM_TIME, 108), 108),
           @NOT_SEND_SMS_TO_TIME = convert(datetime, convert(varchar(8), NOT_SEND_SMS_TO_TIME, 108), 108),
           @SMS_TEMPLATE=SMS_TEMPLATE
    from CALL_CENTER_PARAMS where AUTO_SMS_REM_ON_RECEPTION = 1

	select @SMS_TEMPLATE_FIRST ='Вы записаны на прием в клинику %ExamTime% Телефон: +74991234567 Адрес на карте: https://goo.gl/maps/oo'
	select @SMS_TEMPLATE_LN='Вы записаны на прием в клинику %ExamTime% Для переноса или отмены записи, пожалуйста, сообщите по телефону +74951234545 Адрес на карте: https://goo.gl/w'

    if (@SEND_SMS_FOR_N_HOURS is not null) and (@SMS_TEMPLATE is not null)
    begin
      declare @TimeNotify datetime, @CurrentDate datetime

        DECLARE @SMS_MESSAGES_ID int, @REC_ID int, @DateNotify datetime, @StartDate datetime,
                @PatientsID int, @PatientsPhone varchar(20), @IsAccepted bit,
                @MedecinName varchar(60), @SubjName varchar(60), @ExamName varchar(60)
				,@PL_SUBJ_ID int

        DECLARE SMS_CUR CURSOR LOCAL FORWARD_ONLY FOR
          SELECT h.SMS_MESSAGES_ID, i.PLANNING_ID, i.DATE_START,
                 isnull(m.nom, ''), isnull(pl_subj.name, ''), isnull(pl_exam.name, '')
				 ,pl_subj.PL_SUBJ_ID
				 ,i.PATIENTS_ID
				 ,case when len(i.phone)>6 then i.phone
					else p.MOBIL_TELEFON end		--приоритет телефона из расписания
				 ,case when isnull(d.NOT_ACCEPTED, 0) = 1 and isnull(i.NOT_ACCEPTED, 0) = 0 then 1 else 0 end,
                 case when i.status = 1 then 1
                      when i.CANCELLED = 1 then 1
                      else 0
                 end as IsCanceled,
                 case when d.planning_id is null then 0 else 1 end as IsModified
          from inserted i 
			inner loop join PATIENTS p on p.PATIENTS_ID = i.PATIENTS_ID and isnull(p.NOT_SEND_SMS, 0) = 0 and (len(p.MOBIL_TELEFON)>0 or len(i.phone)>6)
              inner loop join pl_subj on pl_subj.pl_subj_id = i.pl_subj_id and isnull(pl_subj.NO_SMS_NOTIFY, 0) = 0
              inner loop join pl_exam on pl_exam.pl_exam_id = i.pl_exam_id and isnull(pl_exam.NO_SMS_NOTIFY, 0) = 0
              left outer join deleted d on d.PLANNING_ID = i.PLANNING_ID
              left outer join SMS_MESSAGES h on h.REC_ID = i.PLANNING_ID and h.REC_TYPE = 'PLANNING_AUTO_NOTIFY' and isnull(h.STATUS, 0) in (0, 1)
              left outer join medecins m on m.medecins_id = pl_subj.medecins_id
          where isnull(i.STATUS, 0) in (0, 1) -- Только действующие и удаленные
                and isnull(i.DATE_START, getdate()) > getdate() -- Только если время приема еще не наступило
                and isnull(i.SOURCE_PLANNING_ID, 0) = 0
        OPEN SMS_CUR
        FETCH NEXT FROM SMS_CUR INTO @SMS_MESSAGES_ID, @REC_ID, @StartDate,
                                     @MedecinName, @SubjName, @ExamName
									 ,@PL_SUBJ_ID
                                     ,@PatientsID, @PatientsPhone, @IsAccepted, @IsCanceled, @IsModified
        WHILE @@FETCH_STATUS = 0
        BEGIN
            set @ActionName = case when @IsAccepted = 1 then 'Запись подтверждена'
                                   when @IsCanceled = 1 then 'Запись отменена'
                                   when @IsModified = 1 then 'Запись изменена'
                                   else 'Новая запись'
                              end
            set @ExamTime = convert(varchar(15), @StartDate, 4) + ' в ' + convert(varchar(5), @StartDate, 108)
            
			if @PL_SUBJ_ID=24/*лн*/
				select @SMS_TEMPLATE=@SMS_TEMPLATE_LN

			set @SMS_TEMPLATE = replace(@SMS_TEMPLATE, '%ActionName%', @ActionName)
            set @SMS_TEMPLATE = replace(@SMS_TEMPLATE, '%MedecinName%', @MedecinName)
            set @SMS_TEMPLATE = replace(@SMS_TEMPLATE, '%SpecName%', @SubjName)
            set @SMS_TEMPLATE = replace(@SMS_TEMPLATE, '%ExamName%', @ExamName)
            set @SMS_TEMPLATE = replace(@SMS_TEMPLATE, '%ExamTime%', @ExamTime)
			
			set @SMS_TEMPLATE_FIRST = replace(@SMS_TEMPLATE_FIRST, '%ExamTime%', @ExamTime)		/*предполагается, что записи PLANNING редактируются по одному? */
			
            set @CurrentDate = convert(datetime, convert(varchar(10), GetDate(), 120), 120)

            if @IsCanceled = 1 -- Для отмененных дату напоминания делаем текущей (не зависит от времени приема)
              set @DateNotify = GetDate()
            else -- Для всех остальных формируем дату напоминания от даты и времени приема
              set @DateNotify = Dateadd(hour, -@SEND_SMS_FOR_N_HOURS, @StartDate)

            /* Проверяем софрмированную дату нотификации на принадлежность к режиму молчания */
            if (@NOT_SEND_SMS_FROM_TIME is not null and  @NOT_SEND_SMS_TO_TIME is not null)
            begin
              -- Разделяем вычисленную дату напоминания на отдельные переменные с датой и с временем
              set @TimeNotify = convert(datetime, convert(varchar(8), @DateNotify, 108), 108)
              set @DateNotify = convert(datetime, convert(varchar(10), @DateNotify, 120), 120)

              -- Если мы в периоде молчания, то переносим время напоминания на начало периода молчания и сдвигаем дату на один день назад
              -- Задан тип периода молчания с 22-00 до 09-00
              if (@NOT_SEND_SMS_FROM_TIME > @NOT_SEND_SMS_TO_TIME
                 and (@TimeNotify >= @NOT_SEND_SMS_FROM_TIME or @TimeNotify <= @NOT_SEND_SMS_TO_TIME))
              begin
                -- Если время напоминания меньше @NOT_SEND_SMS_TO_TIME (утро), то сдвигаем напоминание на день назад
                if @TimeNotify <= @NOT_SEND_SMS_TO_TIME
                  set @DateNotify = @DateNotify - 1
                set @TimeNotify = @NOT_SEND_SMS_FROM_TIME

                -- В случае отмены записи, если время нотификации уже прошло, то переносим его на конец периода молчания + 1 день
                if @IsCanceled = 1 and @DateNotify + @TimeNotify < GetDate()
                begin
                  set @DateNotify = @CurrentDate + 1
                  set @TimeNotify = @NOT_SEND_SMS_TO_TIME
                end
              end
              else
              -- Задан тип периода молчания с 12-00 до 14-00
              if (@NOT_SEND_SMS_FROM_TIME < @NOT_SEND_SMS_TO_TIME
                  and (@TimeNotify >= @NOT_SEND_SMS_FROM_TIME and @TimeNotify <= @NOT_SEND_SMS_TO_TIME))
              begin
                set @TimeNotify = @NOT_SEND_SMS_FROM_TIME
                -- В случае отмены записи, если время нотификации уже прошло, то переносим его на конец периода молчания
                if @IsCanceled = 1 and @DateNotify + @TimeNotify < GetDate()
                  set @TimeNotify = @NOT_SEND_SMS_TO_TIME
              end

              -- Добавляем в дату нотификации новое вычисленное время нотификации (с учетом периода молчания)
              set @DateNotify = @DateNotify + @TimeNotify
            end

            -- Просроченные нотификации не отправляем
            if @DateNotify < convert(datetime, convert(varchar(10), GetDate(), 120), 120)
              set @DateNotify = 0
            else -- Если запись создана на сегодня или завтра ИЛИ отменена,
                 -- то напоминание не отправляем (типа пациенты и сами помнят об этом)
            if @IsCanceled = 1 or datediff(HOUR,GETDATE(),@StartDate)<29
              set @DateNotify = 0

			/* В случае если между временем создания записи и 
			временем приема менее 28 часов - уведомление проходит только первичное
			перед созданием первичного уведомления проверка, что оно еще не создано */

            if isnull(@SMS_MESSAGES_ID, 0) > 0
            begin
				/*смс уже созданы*/
              update SMS_MESSAGES set
                 SENDED_DATETIME = @DateNotify,
                 PHONE = @PatientsPhone,
                 PATIENTS_ID = @PatientsID,
                 BODY = @SMS_TEMPLATE
              where SMS_MESSAGES_ID = @SMS_MESSAGES_ID and
					REC_TYPE = 'PLANNING_AUTO_NOTIFY'

              update SMS_MESSAGES set
                 PHONE = @PatientsPhone,
                 PATIENTS_ID = @PatientsID,
                 BODY = @SMS_TEMPLATE_FIRST
              where REC_ID=@REC_ID and
					REC_TYPE = 'PLANNING_FIRST_NOTIFY'

            end
            else
			begin
				/*смс еще нет*/
				if @DateNotify > 0	/*смс для уведомления перед приемом*/
				begin
					exec CreateSMS @PatientsID, @PatientsPhone, @DateNotify, @SMS_TEMPLATE, @REC_ID, 'PLANNING_AUTO_NOTIFY'
				end

				if @IsCanceled = 0	and 
					not exists(select SMS_MESSAGES_ID 
								from SMS_MESSAGES where REC_ID=@REC_ID and REC_TYPE='PLANNING_FIRST_NOTIFY')
				begin
					/*смс для отправки сразу после создания записи*/
					select @DateNotify=DATEADD(MINUTE,15,getdate())
					exec CreateSMS @PatientsID, @PatientsPhone, @DateNotify, @SMS_TEMPLATE_FIRST, @REC_ID, 'PLANNING_FIRST_NOTIFY'
				end
			end

			/*здесь update работает, тк после создания записи медиалог сразу обновляет PLANNING.STATUS  */
			/*установить статус отправки нужно только при создании новой записи*/
			begin
				update PLANNING_USER_EXT set 
					SEND_SMS=1 
				from PLANNING_USER_EXT
				where PLANNING_USER_EXT.PLANNING_ID=@REC_ID
					and datediff(S,KRN_CREATE_DATE,GETDATE())<1

				/* только для расписания лн */
				update PLANNING_USER_EXT set
					SEND_SMS=0 
					,SMS_TEXT=@SMS_TEMPLATE
					,SMS_PERIOD=@SEND_SMS_FOR_N_HOURS
				from PLANNING_USER_EXT
				join PLANNING on PLANNING.PLANNING_ID=PLANNING_USER_EXT.PLANNING_ID
				where PLANNING_USER_EXT.PLANNING_ID=@REC_ID and
					PLANNING.PL_SUBJ_ID in(24/*лн*/) and
					datediff(S,PLANNING.KRN_CREATE_DATE,GETDATE())<1
			end
			----------------

            FETCH NEXT FROM SMS_CUR INTO @SMS_MESSAGES_ID, @REC_ID, @StartDate,
                                         @MedecinName, @SubjName, @ExamName
										 ,@PL_SUBJ_ID
                                         ,@PatientsID, @PatientsPhone, @IsAccepted, @IsCanceled, @IsModified
        END

        CLOSE SMS_CUR
        DEALLOCATE SMS_CUR
      end
  END
end


GO


