EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
GO
RECONFIGURE;
GO

set language english
go

INSERT INTO
--select * from
 OPENROWSET (
	'Microsoft.ACE.OLEDB.12.0'
	,'Excel 12.0; HDR=NO; Database=c:\data\test\test.xls;'
	,'select * from [Лист1$]'
	)
SELECT TOP 5 NOM, PRENOM
FROM PATIENTS




