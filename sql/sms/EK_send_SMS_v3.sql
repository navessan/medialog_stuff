alter PROCEDURE [dbo].[EK_send_SMS_v3] @debug int
as begin
/*
отправка смс из расписания
телефон брать из таблицы смс или из расписания?
*/

/*
SELECT top 50
dbo.TrimNumericCode(Phone) as phone,
 SMS_MESSAGES.SMS_MESSAGES_ID, SMS_MESSAGES.PATIENTS_ID
 ,(cast((PATIENTS.NOM + ' ' + Substring(PATIENTS.PRENOM,1,1) + ' ' + Substring(PATIENTS.PATRONYME,1,1)) AS VARCHAR(100))) pat
  ,SMS_MESSAGES.BODY 
 ,SMS_MESSAGES.STATUS
 , SMS_MESSAGES.SENDED_DATETIME
 , SMS_MESSAGES.REC_ID, SMS_MESSAGES.REC_TYPE 
FROM
 SMS_MESSAGES SMS_MESSAGES WITH(NOLOCK)  
 LEFT OUTER JOIN PATIENTS PATIENTS WITH(NOLOCK) ON PATIENTS.PATIENTS_ID = SMS_MESSAGES.PATIENTS_ID 
 where 
 SMS_MESSAGES.status=1 and
 isnull(NOT_SEND_SMS, 0) = 0
 order by SMS_MESSAGES.SENDED_DATETIME
 */

 set nocount on

declare @mes_id int
,@plan_id int
,@phones nvarchar(64)
,@phones2 nvarchar(64)
,@mes nvarchar(max)
,@pat nvarchar(128)
,@send_time datetime
,@send_time2 nvarchar(64)

DECLARE @body nvarchar(MAX)
		,@body_header nvarchar(MAX)
		,@body_footer nvarchar(MAX)
		,@mail_addr nvarchar(128)
		,@mailitem_id int

SELECT
@body_header = N'sms:100::'--::'


set @debug=0

if(@debug=1)
	select @mail_addr=
	'nov@m;'
else 
	select @mail_addr='nov@m;send@send.smsc.ru'


DECLARE cur CURSOR 
   LOCAL           -- LOCAL or GLOBAL
   FORWARD_ONLY    -- FORWARD_ONLY or SCROLL
   STATIC          -- STATIC, KEYSET, DYNAMIC, or FAST_FORWARD
   READ_ONLY       -- READ_ONLY, SCROLL_LOCKS, or OPTIMISTIC
   TYPE_WARNING    -- Inform me of implicit conversions
FOR
-----------------------
SELECT top 30
SMS_MESSAGES.SMS_MESSAGES_ID
,replace(SMS_MESSAGES.PHONE,';',',')
 ,(cast((PATIENTS.NOM + ' ' + Substring(PATIENTS.PRENOM,1,1) + ' ' + Substring(PATIENTS.PATRONYME,1,1)) AS VARCHAR(100))) pat
  ,SMS_MESSAGES.BODY 
 , SMS_MESSAGES.SENDED_DATETIME
 , SMS_MESSAGES.REC_ID
FROM
 SMS_MESSAGES SMS_MESSAGES WITH(NOLOCK)  
 JOIN PATIENTS PATIENTS WITH(NOLOCK) ON PATIENTS.PATIENTS_ID = SMS_MESSAGES.PATIENTS_ID 
 JOIN PLANNING PLANNING WITH(NOLOCK) ON SMS_MESSAGES.REC_ID= PLANNING.PLANNING_ID
 JOIN PLANNING_USER_EXT WITH(NOLOCK) ON PLANNING.PLANNING_ID=PLANNING_USER_EXT.PLANNING_ID
 join PL_SUBJ on PL_SUBJ.PL_SUBJ_ID=PLANNING.PL_SUBJ_ID
where 
 SMS_MESSAGES.status=1 /*ждет отправки */ and
 (REC_TYPE='PLANNING_AUTO_NOTIFY' or REC_TYPE='PLANNING_FIRST_NOTIFY' )and
 isnull(PATIENTS.NOT_SEND_SMS, 0) = 0 and
 SMS_MESSAGES.SENDED_DATETIME>dateadd(HH,-3,GETDATE()) and	/* за прошедшие часы */
 SMS_MESSAGES.SENDED_DATETIME<dateadd(MINUTE,5,GETDATE()) and		/*к отправке в ближайшее время*/
 --------------------
 PLANNING.PL_SUBJ_ID not in(24/*л*/) and	/* л рассылается отдельно */
 isnull(PL_SUBJ.NO_SMS_NOTIFY,0)=0 and	--включено в настройках расписания
 PLANNING.DATE_START > getdate() and
 isnull(PLANNING.STATUS,0)=0 and		--действующие записи
 isnull(PLANNING.CANCELLED,0)=0 and
 isnull(PLANNING_USER_EXT.SEND_SMS,0)=1 and		--стоит галочка отправки
 --isnull(PLANNING_USER_EXT.SMS_SENDED,0)=0 and	--еще не отправленные  зачем здесь?
 datalength(SMS_MESSAGES.BODY)>10 and			--текст заполнен
 --datalength(PLANNING_USER_EXT.SMS_TEXT)>10 and	--текст заполнен
 isnull(PATIENTS.NOT_SEND_SMS, 0) = 0 and		--пациент не запретил рассылку
 isnull(PATIENTS.DOSSIER_EXIT,0)=0				--пациент не умер
 --and SMS_MESSAGES.SMS_MESSAGES_ID=26
 order by SMS_MESSAGES.SENDED_DATETIME desc
-----------------------
OPEN Cur;
FETCH NEXT FROM Cur into 
		@mes_id
		,@phones
		,@pat
		,@mes
		,@send_time
		,@plan_id;
WHILE @@FETCH_STATUS = 0
	BEGIN
	---------------------------------

/*debug*//*
if (@debug=1)
	set @phones='7915,7968'
	--796,
*/

--select @phones,CHARINDEX(',',@phones)
/* используется только первый номер до запятой */
if(CHARINDEX(',',@phones)>0)
	select @phones=SUBSTRING(@phones,1,CHARINDEX(',',@phones)-1)


select @phones=dbo.PreparePhone(@phones,'7',null)

/*формат даты 
DD.MM.YY hh.mm
*/
select @send_time2=replace(convert(varchar,@send_time,4)+' '+convert(varchar(5),@send_time,8),':','.')

select @body=@body_header
	+@send_time2
	+'::'
	+@phones
	+':'
	+@mes


select @send_time as time, cast(@body as varchar(512)) as body
/*
Для отправки SMS необходимо послать e-mail на адрес send@send.smsc.ru с текстом в формате:
<login>:<psw>:<id>:<time>,<tz>:<translit>,<format>,<sender>,<test>:<phones>:<mes>
alex:123::::79999999999:сообщение 
*/

EXEC msdb.dbo.sp_send_dbmail @profile_name = 'eu', @recipients =@mail_addr, @subject = 'sms', @body = @body, @mailitem_id = @mailitem_id OUTPUT

select @mailitem_id as mailitem_id

--	if(@debug=0)
		update SMS_MESSAGES 
		set status=2
		where SMS_MESSAGES_ID=@mes_id
	
	---------------------------------
		FETCH NEXT FROM Cur into 
		@mes_id
		,@phones
		,@pat
		,@mes
		,@send_time
		,@plan_id;
	END;
CLOSE Cur;
DEALLOCATE Cur;

end -- procedure