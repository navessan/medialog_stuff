DECLARE @DeleteDate datetime
		,@path varchar(255)
SELECT @DeleteDate = DateAdd(day, -30, GetDate())
	,@path=N'D:\LAB\backup\'
/*
\\buhsrv\data\sql_backup\HR_Report\
\\buhsrv\data_2\sql_backup\sklad\
\\storage\obmen\backup\buh\
\\medialog-new\backup\medialog7\
*/

EXECUTE master.sys.xp_delete_file
0, -- FileTypeSelected (0 = FileBackup, 1 = FileReport)
@path, -- folder path (trailing slash)
N'bak', -- file extension which needs to be deleted (no dot)
@DeleteDate, -- date prior which to delete
1 -- subfolder flag (1 = include files in first subfolder level, 0 = not)