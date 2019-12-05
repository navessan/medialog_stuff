EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1
RECONFIGURE
GO

DECLARE 
		@file VARCHAR(1000)
		,@CMD VARCHAR(1000)

select
	@file='C:\temp\PAT_D-zzzz-'+Convert(VARCHAR(20),GetDate(),112)+'T'+'.xml'

SET @CMD = 'bcp "'
	+'select ''<?xml version=""1.0"" encoding=""UTF-8""?>''+char(10)+ ('
	+'select top 10 * from medialog_20.dbo.patients FOR XML PATH (''Patient''), root (''Patients'') '
	+')'
	+'" queryout "' +@file+'.unicode' +'"  -t, -w -C raw -T'

exec master..xp_cmdshell @CMD

select @CMD='PowerShell -Command "Get-Content '+@file+'.unicode' +' | Set-Content -Encoding utf8 '+@file+'"'

exec master..xp_cmdshell @CMD
