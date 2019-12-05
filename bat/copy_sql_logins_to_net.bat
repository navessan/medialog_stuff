
set src=c:\data\backup\logins.sql
rem set dst=c:\data\backup\SQL\
set dst=\\192.168.60.6\data\backups\medialog\logins\

set log=c:\data\netcopy_backup.log

set T_Date=%DATE%
IF %T_DATE:~0,1%==0 (
  SET /A T_DAY=%T_DATE:~1,1%) else (
  SET /A T_DAY=%T_DATE:~0,2%)
 
IF %T_DATE:~3,1%==0 (
   SET /A T_MONTH=%T_DATE:~4,1%) else (
   SET /A T_MONTH=%T_DATE:~3,2%)
 
SET /A T_YEAR=%T_DATE:~6,4%
   
if %T_MONTH% LSS 10 (SET T_MONTH=0%T_MONTH%)
if %T_DAY% LSS 10 (SET T_DAY=0%T_DAY%)

set mydate=%T_YEAR%_%T_MONTH%_%T_DAY%

echo %mydate% >> %log%

copy %src% %dst%\sql_logins_%mydate%.sql >> %log%

