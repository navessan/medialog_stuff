--SQL Server script to rebuild all indexes for all tables and all databases
DECLARE @Database VARCHAR(255)  
DECLARE @Table VARCHAR(255)  
DECLARE @cmd NVARCHAR(500)  
DECLARE @fillfactor INT

set nocount on

SET @fillfactor = 90

DECLARE DatabaseCursor CURSOR FOR  
SELECT 'med' name

OPEN DatabaseCursor  

FETCH NEXT FROM DatabaseCursor INTO @Database  
WHILE @@FETCH_STATUS = 0  
BEGIN  

   SET @cmd = 'DECLARE TableCursor CURSOR FOR SELECT ''['' + table_catalog + ''].['' + table_schema + ''].['' +
  table_name + '']'' as tableName FROM ' + @Database + '.INFORMATION_SCHEMA.TABLES
  WHERE table_type = ''BASE TABLE''
  and table_name not like ''KRN%''
  order by table_name
  '  

   -- create table cursor  
   EXEC (@cmd)  
   OPEN TableCursor  

   FETCH NEXT FROM TableCursor INTO @Table  
   WHILE @@FETCH_STATUS = 0  
   BEGIN  

       IF (@@MICROSOFTVERSION / POWER(2, 24) >= 9)
       BEGIN
           -- SQL 2005 or higher command
           SET @cmd = 'ALTER INDEX ALL ON ' + @Table + ' REBUILD WITH (FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ')'
           EXEC (@cmd)

		   select @cmd
       END
       ELSE
       BEGIN
          -- SQL 2000 command
          DBCC DBREINDEX(@Table,' ',@fillfactor)  
       END

       FETCH NEXT FROM TableCursor INTO @Table  
   END  

   CLOSE TableCursor  
   DEALLOCATE TableCursor  

   FETCH NEXT FROM DatabaseCursor INTO @Database  
END  
CLOSE DatabaseCursor  
DEALLOCATE DatabaseCursor 