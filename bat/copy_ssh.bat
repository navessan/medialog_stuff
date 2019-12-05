
set log=c:\data\ssh.log

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

set mydate=%T_YEAR%-%T_MONTH%-%T_DAY%

echo %mydate% >> %log%

set program=c:\soft\WinSCP\WinSCP.exe /log="%log%" /ini=nul /command "open sftp://user@1.1.1.1:8889/ -hostkey=""ssh-rsa 2048 ec:b5:xxxxxxx"" -privatekey=""C:\data\scripts\1.ppk"""

set src_dir=c:\data\backup\SQL\
set dst=/share/MD0_DATA/Public/backups/medialog/sql
set filez=medialog_%mydate%_*.bak

%program% "lcd %src_dir%" "cd %dst%" "put -transfer=automatic %filez%" "exit"

set src_dir=c:\data\backup\FS\
set dst=/share/MD0_DATA/Public/backups/medialog/fs
set filez=%T_YEAR%%T_MONTH%%T_DAY%_medialog*.zip

%program% "lcd %src_dir%" "cd %dst%" "put -transfer=automatic %filez%" "exit"

set src_dir=c:\data\backup\
set dst=/share/MD0_DATA/Public/backups/medialog/logins
set filez=logins.sql
set r_filez=logins_%mydate%.sql

%program% "lcd %src_dir%" "cd %dst%" "put -transfer=automatic %filez% %r_filez%" "exit"

