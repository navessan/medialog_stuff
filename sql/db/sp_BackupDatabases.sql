CREATE PROCEDURE [dbo].[sp_BackupDatabases]  
            @databaseName sysname = null,
            @backupType CHAR(1),
            @backupLocation nvarchar(200) 
AS 

	SET NOCOUNT ON; 

	DECLARE @DBs TABLE(
			ID int IDENTITY PRIMARY KEY,
			DBNAME nvarchar(500)
	)

	-- Pick out only databases which are online in case ALL databases are chosen to be backed up
	-- If specific database is chosen to be backed up only pick that out from @DBs
	INSERT INTO @DBs (DBNAME)
		SELECT Name 
		FROM master.sys.databases
		where state=0
			AND name=@DatabaseName
			OR @DatabaseName IS NULL
		ORDER BY Name

	-- Filter out databases which do not need to backed up
	IF @backupType='F'
		BEGIN
		DELETE @DBs where DBNAME IN ('tempdb','Northwind','pubs','AdventureWorks')
		END
	ELSE IF @backupType='D'
		BEGIN
		DELETE @DBs where DBNAME IN ('tempdb','Northwind','pubs','master','AdventureWorks')
		END
	ELSE IF @backupType='L'
		BEGIN
		DELETE @DBs where DBNAME IN ('master','model','msdb','tempdb','ReportServerTempDB')
		END
	ELSE
		BEGIN
		RETURN
		END

	-- Declare variables
	DECLARE @BackupName varchar(100)
			,@BackupFile varchar(100)
			,@Path varchar(300)
			,@DBNAME varchar(300)

			,@sqlCommand NVARCHAR(1000) 
			,@dateTime NVARCHAR(20)
			,@Loop int                  

	-- Loop through the databases one by one
	SELECT @Loop = min(ID) FROM @DBs

	WHILE @Loop IS NOT NULL
	BEGIN
		-- Database Names have to be in [dbname] format since some have - or _ in their name
		SELECT @DBNAME = DBNAME FROM @DBs WHERE ID = @Loop

		-- Set the current date and time n yyyyhhmmss format
		SET @dateTime = REPLACE(CONVERT(VARCHAR(10), GETDATE(),120),'-','') + '_' +  REPLACE(CONVERT(VARCHAR, GETDATE(),108),':','')

		-- create subdir
		SET @Path=@backupLocation+'\'+@DBNAME+'\'
		EXECUTE master.dbo.xp_create_subdir @Path

		-- Create backup filename in path\filename.extension format for full,diff and log backups
		IF @backupType = 'F'
			SET @BackupFile = @Path + @DBNAME + '_'+ @dateTime+ '_FULL.BAK'
		ELSE IF @backupType = 'D'
			SET @BackupFile = @Path + @DBNAME + '_'+ @dateTime+ '_DIFF.BAK'
		ELSE IF @backupType = 'L'
			SET @BackupFile = @Path + @DBNAME + '_'+ @dateTime+ '_LOG.TRN'

		-- Provide the backup a name for storing in the media
		IF @backupType = 'F'
			SET @BackupName = @DBNAME +' full backup for '+ @dateTime
		IF @backupType = 'D'
			SET @BackupName = @DBNAME +' differential backup for '+ @dateTime
		IF @backupType = 'L'
			SET @BackupName = @DBNAME +' log backup for '+ @dateTime

		-- Generate the dynamic SQL command to be executed

		IF @backupType = 'F' 
			SET @sqlCommand = 'BACKUP DATABASE [' +@DBNAME+  '] TO DISK = '''+@BackupFile+ ''' WITH INIT, NAME= ''' +@BackupName+''', NOSKIP, NOFORMAT'

		IF @backupType = 'D'
			SET @sqlCommand = 'BACKUP DATABASE [' +@DBNAME+  '] TO DISK = '''+@BackupFile+ ''' WITH DIFFERENTIAL, INIT, NAME= ''' +@BackupName+''', NOSKIP, NOFORMAT'        

		IF @backupType = 'L' 
			SET @sqlCommand = 'BACKUP LOG [' +@DBNAME+  '] TO DISK = '''+@BackupFile+ ''' WITH INIT, NAME= ''' +@BackupName+''', NOSKIP, NOFORMAT'        

		-- Execute the generated SQL command
		select 'execute: '+@sqlCommand
		EXEC(@sqlCommand)

		-- Goto the next database
		SELECT @Loop = min(ID) FROM @DBs where ID>@Loop

END

GO


