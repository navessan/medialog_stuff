/*DBCC TRACEON (3604);
GO
DBCC PAGE (nuzbuh8r, 1, 999588, 3);
*/
/*
BACKUP LOG nuzbuh8r TO DISK = 'd:\data\sql_backup\NuzBuh\broken_log.bak' WITH INIT;
GO

USE master;
GO
RESTORE DATABASE nuzbuh8r PAGE = '1:999588' FROM DISK = 'd:\data\sql_backup\NuzBuh\NuzBuh8_1_backup_201105082215.bak';
*/
RESTORE LOG nuzbuh8r FROM DISK = 'd:\data\sql_backup\NuzBuh\broken_log.bak';
GO
