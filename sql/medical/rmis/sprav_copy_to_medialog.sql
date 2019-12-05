declare @table as varchar(32)
declare @table_prefix as varchar(32)
declare @sql as varchar(512)
declare @sql_1 as varchar(512)

set @table_prefix='US_OMS_'

--copy tables data
set @sql_1='
truncate table '+@table_prefix+'_table_
insert into '+@table_prefix+'_table_
(code,name)
select code,name from _table_
/*drop table _table_*/
'

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



set @sql_1='
truncate table '+@table_prefix+'_table_
insert into '+@table_prefix+'_table_
(s_regn,s_ogrn,s_name)
select s_regn,s_ogrn,s_name from _table_
/*drop table _table_*/
'
set @table='cl0700'
set @sql=replace(@sql_1, '_table_', @table)
select @sql
exec(@sql)
