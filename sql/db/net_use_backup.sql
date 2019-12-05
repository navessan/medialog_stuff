
-- enable xp_cmdshell
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1
RECONFIGURE
GO

EXEC xp_cmdshell 'net use l: \\10.1.1.1\backups /user:domain\username PASSWORD'
--EXEC xp_cmdshell 'net use l: \\storage\backup'

GO

--EXEC xp_cmdshell 'net use l: /delete'

-- disable xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 0
RECONFIGURE
GO

/*
--BACKUP DATABASE Buh8_1 TO DISK='d:\data\sql_backup\Buh\broken.bak'
--WITH CHECKSUM, CONTINUE_AFTER_ERROR;

RESTORE DATABASE [medialog7_back] 
FROM  DISK = N'F:\data\backup\medialog7\medialog7_backup_201310212200.bak' WITH  FILE = 1,
  MOVE N'MEDIALOG_Data' TO N'd:\data\sql\medialog7_back.mdf',
  MOVE N'MEDIALOG_log' TO N'e:\data\sql\medialog7_back_log.ldf',  NOUNLOAD,  REPLACE,  STATS = 10
, CONTINUE_AFTER_ERROR;

*/
