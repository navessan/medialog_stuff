
alter procedure us_patient2xml_v3
	@patients_id int
	--,@RESULT_XML varchar(max) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

declare
	@motconsu_id int
	,@RESULT_XML varchar(max) 
/*
select
@patients_id=160918
,@motconsu_ID=11599099
*/
declare 
	@table_name varchar(128)
	,@descr  varchar(1024)
	,@sql_template varchar(max)
	,@sql nvarchar(max)
	,@t_res nvarchar(max)

/* список таблиц связанных с пациентом */
declare @pat_tables table(name varchar(256), descr varchar(1024)) 

insert into @pat_tables
select distinct
	t.table_name
	,cast (t.custom as varchar(max)) as descr
from metafield as f
join metatable as t on f.table_name=t.table_name
where field_name='patients_id'
	and t.table_name not like 'fm%'
	and t.table_name not like 'view%'
	and t.table_name not like 'vw%'
	and t.table_name not like 'LIS_RESULTS'
order by t.table_name

/* выходные данные */
--check for temp table, and drop if necessary
IF object_id('tempdb..##tout') IS NOT NULL
BEGIN
	DROP TABLE ##tout
END

create table ##tout(id int identity(1,1),d varchar(max))

select
@sql_template='select * from _TABLE_ where patients_id=_patients_id_ for XML AUTO'
,@RESULT_XML='<?xml version="1.0" encoding="UTF-8"?>'

insert into ##tout values(@RESULT_XML)

/* начало инфы о пациенте */
insert into ##tout values(
	'<PATIENT>')

	declare tableCursor CURSOR FORWARD_ONLY for
	------
	select
	name, descr
	from @pat_tables order by name
	------
	OPEN tableCursor

	WHILE (1=1)
	BEGIN
	-------------
		FETCH NEXT FROM tableCursor INTO @table_name, @descr
		IF(@@FETCH_STATUS<>0)
			BREAK;
		select @sql=replace(@sql_template,'_TABLE_',@table_name)
		select @sql=replace(@sql,'_patients_id_',@patients_id)
		
		select @sql='select @res=('+@sql+')'
		--select @sql
		exec sp_executesql @sql, N'@res varchar(max) output', @t_res output;
		--select @t_res
		if(len(@t_res)>0)
		begin
			insert into ##tout 
				select '<TABLE_'+@table_name+'>'
			insert into ##tout values(@t_res)	
			insert into ##tout 
				select '</TABLE_'+@table_name+'>'
		end
	-------------
	END
	CLOSE tableCursor
	DEALLOCATE tableCursor

/* конец инфы о пациенте */
insert into ##tout values('</PATIENT>')
-------------

/* fckng end*/
--select @RESULT_XML
--select d from ##tout 
END;