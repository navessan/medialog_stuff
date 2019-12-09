CREATE PROCEDURE [dbo].[sp_ShrinkDatabases]  
            @databaseName sysname = null 
AS 

	SET NOCOUNT ON; 

	-- Declare variables
	DECLARE @DBNAME varchar(300)
		,@Filename nvarchar(100)
		,@sqlCommand NVARCHAR(1000) 

DECLARE cur CURSOR LOCAL READ_ONLY FORWARD_ONLY FOR
-----------------
	SELECT 
		d.name,mf.name--,size/128
	FROM sys.master_files mf 
	JOIN sys.databases d ON mf.database_id = d.database_id 
	WHERE 
	d.database_id > 4	-- 'master','model','msdb','tempdb'
	and mf.type_desc = 'LOG'
	and d.state=0
	and d.name not in ('master','model','msdb','tempdb','ReportServer','ReportServerTempDB')
	and (d.name=@databaseName or @databaseName is null)
	and mf.size/128 > 100 -- megabytes

OPEN cur
 
FETCH NEXT FROM cur INTO @DBNAME,@Filename
 
WHILE @@FETCH_STATUS = 0 
BEGIN

    select @sqlCommand='USE [' + @DBNAME + ']'
		+ CHAR(13) + CHAR(10) 
	    + 'DBCC SHRINKFILE (N''' + @Filename + N''' , 0, TRUNCATEONLY)' 
		+ CHAR(13) + CHAR(10) 
		+ 'DBCC SHRINKFILE (N''' + @Filename + N''' , 100)' 
	select 'execute: '+@sqlCommand
	EXEC sys.sp_executesql @sqlCommand
 
	FETCH NEXT FROM cur INTO @DBNAME,@Filename
	
END
 
CLOSE cur
DEALLOCATE cur

GO


