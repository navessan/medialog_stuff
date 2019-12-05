/*
alter database medialog71 set trustworthy on
*/

drop FUNCTION RunningTotal
drop ASSEMBLY RunningTotal

CREATE ASSEMBLY RunningTotal
FROM 'C:\temp\RunningTotal.dll'
WITH PERMISSION_SET = UNSAFE;
GO

CREATE FUNCTION RunningTotal (@amount decimal(18,2), @context nvarchar(32))
RETURNS decimal(18,2)
AS EXTERNAL NAME RunningTotal.[RunningTotal.RunningTotalUtils].RunningTotal;
GO

/*
EXEC sp_configure 'show advanced options' , '1';
go
reconfigure;
go
EXEC sp_configure 'clr enabled' , '1'
go
reconfigure;
-- Turn advanced options back off
EXEC sp_configure 'show advanced options' , '0';
go
*/
