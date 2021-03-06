USE [msdb]
GO
/****** Object:  Job [ev_close]    Script Date: 09/22/2015 20:48:03 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 09/22/2015 20:48:03 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ev_close', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [1]    Script Date: 09/22/2015 20:48:03 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use medialog7

declare @period datetime
	,@LAST_MOTCONSU_ID int
	,@MOTCONSU_EV_ID int

/* {ts ''2015-05-01 00:00:00.000''} */

/* previous month */
select @period = DATEADD(month, -1, getdate() )
select @period as period

DECLARE cur CURSOR FOR
------
SELECT 
MOTCONSU_EV_ID
,(select top 1 MOTCONSU_ID
	from motconsu sub 
	where sub.MOTCONSU_EV_ID= MOTCONSU.MOTCONSU_ID
	  order by sub.DATE_CONSULTATION desc
) last_ID
--, ev_name
--,*
FROM MOTCONSU
WHERE
    MOTCONSU.DATE_CONSULTATION>= DATEADD(month, DATEDIFF(month, 0, @period), 0)  
and MOTCONSU.DATE_CONSULTATION< DATEADD(month, DATEDIFF(month, 0, @period)+1, 0)  
and MOTCONSU_EV_ID=MOTCONSU_ID
and isnull(EV_CLOSE,0)=0 
and isnull(MOTCONSU_EVENT_TYPES_ID,0) not in (3,4) /* disp, prof302 */
-----

OPEN Cur;
FETCH NEXT FROM Cur into @MOTCONSU_EV_ID, @LAST_MOTCONSU_ID;
WHILE @@FETCH_STATUS = 0
   BEGIN
--------------------------
select @MOTCONSU_EV_ID as MOTCONSU_EV_ID
	  ,@LAST_MOTCONSU_ID as LAST_MOTCONSU_ID

update ev_close set
ev_close.ZAPIS_ZAKR_VAYHAQ_SOB_TIE=1
from motconsu ev_close
where
ev_close.motconsu_id=@LAST_MOTCONSU_ID

update ev_open set
ev_open.EV_CLOSE=1,
ev_open.EV_DATE_CLOSE=getdate(),
ev_open.DATA_ZAKR_TIQ_SLUHAQ_OBRA=getdate()
from motconsu ev_open 
where
motconsu_id=@MOTCONSU_EV_ID

--------------------------
      FETCH NEXT FROM Cur into @MOTCONSU_EV_ID, @LAST_MOTCONSU_ID;
   END;
CLOSE Cur;
DEALLOCATE Cur;
', 
		@database_name=N'medialog7', 
		@output_file_name=N'D:\data\sql\ev_close.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every month on day 1', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20150831, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
