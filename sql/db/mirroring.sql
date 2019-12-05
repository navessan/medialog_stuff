/* backup main */

/*
BACKUP DATABASE [sklad] TO  DISK = N'D:\data\sql_backup\sklad\sklad_backup_201410031354.bak' 
WITH NOFORMAT, NOINIT,  NAME = N'sklad_backup', SKIP, REWIND, NOUNLOAD,  STATS = 10

BACKUP LOG [sklad] TO  DISK = N'D:\data\sql_backup\sklad\sklad_backup_201410031354.trn' 
WITH NOFORMAT, NOINIT,  NAME = N'sklad_backup', SKIP, REWIND, NOUNLOAD,  STATS = 10

--BACKUP LOG MIRROR_TEST TO DISK = 'D:\MIRROR_TEST.trn'
*/

/* restore mirror */
/*
ALTER DATABASE [sklad] SET PARTNER off

RESTORE DATABASE [sklad]
FROM  DISK = N'F:\data\backup\sklad\sklad_backup_201410031354.bak' WITH  FILE = 1,
  MOVE 'sklad' TO N'd:\data\sql\sklad.mdf',
  MOVE 'sklad_log' TO N'e:\data\sql\sklad_log.ldf',  NOUNLOAD,  REPLACE,  STATS = 10
, CONTINUE_AFTER_ERROR
, NORECOVERY;

RESTORE LOG [sklad] FROM DISK = 'F:\data\backup\sklad\sklad_backup_201410031354.trn' WITH NORECOVERY
----
RESTORE DATABASE [medialog7] 
FROM  DISK = N'F:\data\backup\medialog7\medialog7_backup_201310212200.bak' WITH  FILE = 1,
  MOVE N'MEDIALOG_Data' TO N'd:\data\sql\medialog7.mdf',
  MOVE N'MEDIALOG_log' TO N'e:\data\sql\medialog7_log.ldf',  NOUNLOAD,  REPLACE,  STATS = 10
, CONTINUE_AFTER_ERROR;

--RESTORE LOG MIRROR_TEST FROM DISK = 'D:\MIRROR_TEST.trn' WITH NORECOVERY
*/


/* on mirror */
--ALTER DATABASE [sklad] SET PARTNER = N'TCP://buhsrv.domain.local:5022'

/* on main */
/*
ALTER DATABASE [sklad] SET PARTNER = N'TCP://medialog-new.domain.local:5022'
ALTER DATABASE [sklad] SET SAFETY OFF
*/

-------------------------------------------------
--ALTER DATABASE medialog7 SET PARTNER OFF
--RESTORE DATABASE [medialog7] with recovery

/* on mirror after main error */
--ALTER DATABASE MIRROR_TEST SET PARTNER FORCE_SERVICE_ALLOW_DATA_LOSS
