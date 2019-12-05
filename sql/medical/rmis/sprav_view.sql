declare @table as varchar(32)
declare @table_prefix as varchar(32)
declare @sql as varchar(512)
declare @sql_1 as varchar(512)

set @table_prefix='US_OMS_'

set @sql_1='
select top 10 * from _table_'

DECLARE Cur CURSOR FOR
select name 
from sys.objects
where type='U'and name like @table_prefix+'cl%';

OPEN Cur;
FETCH NEXT FROM Cur into @table;
WHILE @@FETCH_STATUS = 0
   BEGIN
	set @sql=replace(@sql_1, '_table_', @table)
	--select @sql
	exec(@sql)
      FETCH NEXT FROM Cur into @table;
   END;
CLOSE Cur;
DEALLOCATE Cur;
