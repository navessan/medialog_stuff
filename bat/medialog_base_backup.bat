
set backup_dir=c:\data\backup\FS
rem set backup_dir=\\192.168.60.6\data\backups\medialog\FS\
set src_dir=c:\medialog\SYS\
set excl_list=c:\data\scripts\excl.txt

set log=c:\data\base_zip.log

set program=c:\soft\7za\7za a -r -tzip

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

set mydate=%T_YEAR%%T_MONTH%%T_DAY%

echo %mydate% >> %log%

%program% -x@%excl_list% %backup_dir%\%mydate%_medialog_FS.zip %src_dir%\* >> %log%

%program%  %backup_dir%\%mydate%_medialog_IMAGES.zip %src_dir%\IMAGES\* >> %log%
%program%  %backup_dir%\%mydate%_medialog_LETTERS.zip %src_dir%\LETTERS\* >> %log%


set dst=\\192.168.60.6\data\backups\medialog\FS\
set log=c:\data\base_copy.log

copy %backup_dir%\%mydate%_*.zip %dst% >> %log%

