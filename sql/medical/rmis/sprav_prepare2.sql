declare @table as varchar(32)
declare @table_prefix as varchar(32)
declare @sql as varchar(1024)
declare @sql_1 as varchar(1024)

set @table_prefix='US_OMS_'
--set @table='cl0100'

--add identity column
set @sql_1='
Alter Table _table_ Drop CONSTRAINT PK__table_
Alter Table _table_ Drop Column ID
alter table _table_ add [id] [int] IDENTITY(1,1) NOT NULL
ALTER TABLE _table_ ADD CONSTRAINT
	PK__table_ PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
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
