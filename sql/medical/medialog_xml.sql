set nocount on

declare 
	@motconsu_id int
	,@patients_id int

select
@patients_id=160918
,@motconsu_ID=11599099

declare 
	 @m_tables varchar(max)
	,@table_prefix varchar(128)
	,@table_prefix2 varchar(128)
	,@table_name varchar(128)
	,@sql_template varchar(max)
	,@sql nvarchar(max)
	,@t_res nvarchar(max)
	,@BFG_res nvarchar(max)

select
@table_prefix='{R}[T]W76_'
,@table_prefix2='{R}[T]'
,@sql_template='select * from _TABLE_ where motconsu_id=_motconsu_id_ for XML PATH(''_TABLE_'')'
,@BFG_res=''

/* начало инфы о пациенте */
select @BFG_res=@BFG_res
	+char(10)+'<PATIENT>'

select @t_res=(
	select * from patients
	where patients_ID=@patients_id
	for xml path('') )

--select @t_res
select @BFG_res=@BFG_res
	+char(10)+@t_res

/* курсор по записям пациента */
declare motCursor cursor 
   LOCAL           -- LOCAL or GLOBAL
   FORWARD_ONLY    -- FORWARD_ONLY or SCROLL
   STATIC          -- STATIC, KEYSET, DYNAMIC, or FAST_FORWARD
   READ_ONLY       -- READ_ONLY, SCROLL_LOCKS, or OPTIMISTIC
   TYPE_WARNING    -- Inform me of implicit conversions
for
------
select top 10
motconsu_id
from  motconsu_xml
where patients_id=@patients_id
------
OPEN motCursor

WHILE (1=1)
BEGIN
-------------
	FETCH NEXT FROM motCursor INTO @motconsu_id
	IF(@@FETCH_STATUS<>0)
		BREAK;
	
	/* начало инфы о текущей записи */
	select @BFG_res=@BFG_res
		+char(10)+'<MOTCONSU>'

	select @t_res=(
		select * from motconsu
		where motconsu_ID=@motconsu_id
		for xml path('') )

	--select @t_res
	select @BFG_res=@BFG_res
		+char(10)+@t_res

	/* ищем заполненые таблицы в текущей записи */
	select @m_tables=filled_tables
	from  motconsu_xml
	where motconsu_ID=@motconsu_ID

	declare tableCursor CURSOR FORWARD_ONLY for
	------
	select
	replace(replace(items,@table_prefix,''),@table_prefix2,'')
	from dbo.strsplit(@m_tables,';')
	------
	OPEN tableCursor

	WHILE (1=1)
	BEGIN
	-------------
		FETCH NEXT FROM tableCursor INTO @table_name
		IF(@@FETCH_STATUS<>0)
			BREAK;
		select @sql=replace(@sql_template,'_TABLE_',@table_name)
		select @sql=replace(@sql,'_motconsu_id_',@motconsu_id)
		
		select @sql='select @res=('+@sql+')'
		--select @sql
		--exec sp_executesql @sql, N'@res varchar(max) output', @t_res output;
		select @t_res=''
		select @BFG_res=@BFG_res
			+char(10)+@t_res	
	-------------
	END
	CLOSE tableCursor
	DEALLOCATE tableCursor

	/* конец инфы из отдельной записи */
	select @BFG_res=@BFG_res
		+char(10)+'</MOTCONSU>'
-------------
END
CLOSE motCursor
DEALLOCATE motCursor


/* конец инфы о пациенте */
select @BFG_res=@BFG_res
	+char(10)+'</PATIENT>'
-------------

/* fckng end*/
select @BFG_res