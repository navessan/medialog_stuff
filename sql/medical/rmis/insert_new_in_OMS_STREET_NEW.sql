declare @P1 int
declare @cod varchar(20)
declare @name varchar(200)
--таблица куда импортируются данные
declare @KeyName varchar(30)
set @KeyName='OMS_STREET_NEW'

--установка значения счетчика в медиалоге, если предыдущие данные импортировались вручную без identity
exec up_get_id  @KeyName, @Shift = 1, @ID = @P1 output
select @P1 old_id

declare @max_id integer
select @max_id=max(OMS_STREET_NEW_id) from OMS_STREET_NEW
select @max_id max_id

if (@max_id>@P1)
begin
	declare @Shift integer
	set @Shift = (@max_id-@P1)
	exec up_get_id  @KeyName, @Shift , @ID = @P1 output
	select @P1 new_id
end


--запрос для импорта данных с проверкой дублирования
DECLARE data_Cursor CURSOR FOR
(
SELECT code,[name]
  FROM cl0677_new new
where new.code not in(select codfond from OMS_STREET_NEW)
)	

--построчный импорт с установкой ID
OPEN data_Cursor;
FETCH NEXT FROM data_Cursor into @cod,@name;
WHILE @@FETCH_STATUS = 0
   BEGIN
		exec up_get_id  @KeyName, @Shift = 1, @ID = @P1 output
		insert into OMS_STREET_NEW
				(OMS_STREET_NEW_id,codfond,[name])
			values(@p1,@cod,@name)
      FETCH NEXT FROM data_Cursor into @cod,@name;
   END;
CLOSE data_Cursor;

DEALLOCATE data_Cursor;

--конец

