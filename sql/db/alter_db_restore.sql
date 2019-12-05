--select @@version

/*
 ALTER DATABASE medialog7
MODIFY FILE
(
    NAME = medialog_data,
    FILENAME = N'd:\data\sql\medialog7.mdf'
);
GO
ALTER DATABASE medialog7
MODIFY FILE
(
    NAME = medialog_log,
    FILENAME = N'g:\data\sql\medialog7_log.ldf'
);
*/
go
/*
RESTORE DATABASE [medialog7] 
	FROM  DISK = N'L:\medialog7\medialog7_backup_201307172200.bak' 
	WITH  FILE = 1,  
	MOVE N'MEDIALOG_Data' TO N'd:\data\sql\medialog7.mdf',  
	MOVE N'MEDIALOG_log' TO N'e:\data\sql\medialog7_log.ldf',  
	NOUNLOAD,  STATS = 10
*/
--ALTER DATABASE medialog7 SET PARTNER OFF
RESTORE DATABASE [medialog7] with recovery