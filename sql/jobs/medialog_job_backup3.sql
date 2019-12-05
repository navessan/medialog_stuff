USE [msdb]
GO

/****** Object:  Job [backup_medialog]    Script Date: 06.05.2016 18:31:17 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 06.05.2016 18:31:17 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'backup_medialog', 
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
/****** Object:  Step [backup_db_to_net]    Script Date: 06.05.2016 18:31:17 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'backup_db_to_net', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/* backup */
DECLARE @DBNAME varchar(300)
,@backupLocation nvarchar(200) 
,@BackupName varchar(100)
,@BackupFile varchar(100)
,@dateTime NVARCHAR(20)
,@type varchar(16)


set datefirst 1

select 
	@type=case when DATEPART(dw,getdate())<7 
		then ''DIFF'' else ''FULL'' end
	,@DBNAME=''med_centre''
	,@backupLocation=''\\10.255.69.40\backups\s\medialog\SQL''

-- Set the current date and time n yyyyhhmmss format
SET @dateTime = REPLACE(replace(CONVERT(VARCHAR, GETDATE(),120),'' '',''_''),'':'','''')

-- Create backup filename in path\filename.extension format for full,diff and log backups
SET @BackupFile = @backupLocation+''\''+@DBNAME+ ''_''+@dateTime+ ''_''+@type+ ''.BAK''

-- Provide the backup a name for storing in the media
SET @BackupName = @DBNAME +'' ''+@type+'' backup for ''+ @dateTime

select @DBNAME,@BackupFile,@BackupName

if(@type=''DIFF'')
	BACKUP DATABASE @DBName TO  DISK = @BackupFile
	WITH DIFFERENTIAL 
	,NAME= @BackupName
	,COMPRESSION
else
begin
	--sunday routine
	BACKUP DATABASE @DBName TO  DISK = @BackupFile
	WITH NAME= @BackupName, COMPRESSION

	SELECT @dateTime = REPLACE(replace(CONVERT(VARCHAR, GETDATE(),120),'' '',''_''),'':'','''')
	,@BackupFile = @backupLocation+''\''+@DBNAME+ ''_''+@dateTime+ ''_LOG.TRN''

	BACKUP LOG @DBName TO  DISK = @BackupFile WITH COMPRESSION

end
', 
		@database_name=N'master', 
		@output_file_name=N'C:\data\DB_backup.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [medialog_base_backup]    Script Date: 06.05.2016 18:31:17 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'medialog_base_backup', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'c:\data\scripts\medialog_base_backup.bat', 
		@output_file_name=N'C:\data\fs_backup2.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_help_revlogin]    Script Date: 06.05.2016 18:31:17 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_help_revlogin', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec sp_help_revlogin', 
		@database_name=N'master', 
		@output_file_name=N'C:\data\backup\logins.sql', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [copy_sql_logins_to_net]    Script Date: 06.05.2016 18:31:17 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'copy_sql_logins_to_net', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'c:\data\scripts\copy_sql_logins_to_net.bat', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'раз в день в 1:01:00', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20151217, 
		@active_end_date=99991231, 
		@active_start_time=10100, 
		@active_end_time=235959, 
		@schedule_uid=N'0c8f9bc8-4f37-4527-8384-711b624a8e58'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


