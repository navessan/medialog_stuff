EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1
RECONFIGURE
GO

DECLARE 
	@file VARCHAR(1000)
	,@CMD VARCHAR(1000)
	,@patient int 

select @patient=160918
select @file='C:\temp\PATIENT-'+convert(varchar(32),@patient)+'-'+Convert(VARCHAR(20),GetDate(),112)+'.xml'

exec medialog7.dbo.us_patient2xml_v3 @patient

SET @CMD = 'bcp "'
	+'select d from ##tout order by id'
	+'" queryout "' +@file+'.unicode' +'"  -t, -w -C raw -T'

select @cmd

exec master..xp_cmdshell @CMD

select @CMD='PowerShell -Command "Get-Content '+@file+'.unicode' +' | Set-Content -Encoding utf8 '+@file+'"'

exec master..xp_cmdshell @CMD

-----------------
EXEC sp_configure 'xp_cmdshell', 0
RECONFIGURE
GO
