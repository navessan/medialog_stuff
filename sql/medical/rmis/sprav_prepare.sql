declare @table as varchar(32)
declare @table_prefix as varchar(32)
declare @sql as varchar(512)
declare @sql_1 as varchar(512)

set @table_prefix='US_OMS_'

--rename tables
set @sql_1='
sp_rename _table_, '+@table_prefix+'_table_'

DECLARE Cur CURSOR FOR
select name 
from sys.objects
where type='U'and name like 'cl%';

OPEN Cur;
FETCH NEXT FROM Cur into @table;
WHILE @@FETCH_STATUS = 0
   BEGIN
	set @sql=replace(@sql_1, '_table_', @table)
	select @sql
	exec(@sql)
      FETCH NEXT FROM Cur into @table;
   END;
CLOSE Cur;
DEALLOCATE Cur;

--add identity column
set @sql_1='
alter table _table_ add [id] [int] IDENTITY(1,1) NOT NULL
select count(*) [count in _table_] from _table_
'

DECLARE Cur CURSOR FOR
select name 
from sys.objects
where type='U'and name like @table_prefix+'cl%';

OPEN Cur;
FETCH NEXT FROM Cur into @table;
WHILE @@FETCH_STATUS = 0
   BEGIN
	set @sql=replace(@sql_1, '_table_', @table)
	select @sql
	exec(@sql)
      FETCH NEXT FROM Cur into @table;
   END;
CLOSE Cur;
DEALLOCATE Cur;
