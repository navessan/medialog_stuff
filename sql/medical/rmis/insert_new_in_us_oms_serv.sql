declare @P1 int
declare @cod varchar(20)
declare @name varchar(200)
declare @moscow varchar(200)
declare @oblast varchar(200)
--таблица куда импортируются данные
declare @KeyName varchar(30)
set @KeyName='US_OMS_TO_OBLAST'

--установка значения счетчика в медиалоге, если предыдущие данные импортировались вручную без identity
exec up_get_id  @KeyName, @Shift = 1, @ID = @P1 output
select @P1 old_id

declare @max_id integer
select @max_id=max(id) from us_oms_cl0677
select @max_id max_id

if (@max_id>@P1)
begin
	declare @Shift integer
	set @Shift = (@max_id-@P1)
	exec up_get_id  @KeyName, @Shift , @ID = @P1 output
	select @P1 new_id
end


--запрос для импорта данных с проверкой дублирования
--COLLATE DATABASE_DEFAULT для исправления ошибки, если базы были в разной кодировке
DECLARE data_Cursor CURSOR FOR
(
SELECT moscow,[name],oblast
  FROM z_oms_mo new
--where new
)	

--построчный импорт с установкой ID
OPEN data_Cursor;
FETCH NEXT FROM data_Cursor into @moscow,@name,@oblast;
WHILE @@FETCH_STATUS = 0
   BEGIN
		exec up_get_id  @KeyName, @Shift = 1, @ID = @P1 output
		insert into US_OMS_TO_OBLAST
				(ID,moscow,[profile],oblast)
			values(@P1,@moscow,@name,@oblast)
      FETCH NEXT FROM data_Cursor into @moscow,@name,@oblast;
   END;
CLOSE data_Cursor;

DEALLOCATE data_Cursor;

--конец

