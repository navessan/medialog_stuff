declare @P1 int
declare @reg varchar(20)
declare @ogrn varchar(20)
declare @name varchar(200)
--таблица куда импортируются данные
declare @KeyName varchar(30)
set @KeyName='OMS_SMO'

--установка значения счетчика в медиалоге, если предыдущие данные импортировались вручную без identity
exec up_get_id  @KeyName, @Shift = 1, @ID = @P1 output
select @P1 old_id

declare @max_id integer
select @max_id=max(OMS_SMO_id) from OMS_SMO
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
select
s_regn,s_ogrn,s_name
  FROM cl0700 new
left join oms_smo on s_name=SMO_NAME and s_regn=SMO_REGION
where new.s_regn not in('50', '77')
and oms_smo_id is null
)	

--построчный импорт с установкой ID
OPEN data_Cursor;
FETCH NEXT FROM data_Cursor into @reg,@ogrn,@name;
WHILE @@FETCH_STATUS = 0
   BEGIN
		exec up_get_id  @KeyName, @Shift = 1, @ID = @P1 output
		insert into OMS_SMO
				(OMS_SMO_id,SMO_REGION,SMO_OGRN,SMO_NAME)
			values(@p1,@reg,@ogrn,@name)
      FETCH NEXT FROM data_Cursor into @reg,@ogrn,@name;
   END;
CLOSE data_Cursor;

DEALLOCATE data_Cursor;

--конец

