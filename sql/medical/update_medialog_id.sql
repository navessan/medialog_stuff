declare @tablename as nvarchar(32)
declare @sql as nvarchar(256)
declare @P1 int
declare @max_id as int
set @max_id=0;

set @tablename='patients'
set @sql='select @max_id=max('+@tablename+'_ID) from '+@tablename
select @sql
exec sp_executesql @sql,N'@max_id int out', @max_id out
select @max_id max_id

exec up_get_id  @tablename, @Shift = 1, @ID = @P1 output
select @P1 old_id

if (@max_id>@P1)
begin
	declare @Shift integer
	set @Shift = (@max_id-@P1)
	exec up_get_id  @tablename, @Shift , @ID = @P1 output
	select @P1 new_id
end