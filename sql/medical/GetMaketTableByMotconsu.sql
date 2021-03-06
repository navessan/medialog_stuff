

alter procedure [dbo].[GetMaketTableByMotconsu] @MaketCode as varchar(256), @Motconsu_ID int
as
	if(isnull(@MaketCode,'')='' or @Motconsu_ID is null)
	begin
		raiserror ('GetMaketTableByMotconsu: Empty input parameters',-1,-1)
		return 1
	end

declare @id int, @row_num int
		,@label varchar(128)
		,@field_name_1 varchar(128)
		,@field_name_2 varchar(128)
		,@table_name varchar(128)
		,@value1 varchar(512)
		,@value2 varchar(512)

set @id=0
declare @tbl table(id int, row_num int, row_name  varchar(128), value1 varchar(512), value2 varchar(512)
							,table_name  varchar(128), field_name_1  varchar(128), field_name_2  varchar(128))

  declare cur cursor local forward_only for
    select row_num, label, table_name, field_name_1, field_name_2 from US_MAKET_TABLE where code=@MaketCode
	order by row_num
  open cur

  FETCH NEXT FROM cur INTO @row_num, @label, @table_name, @field_name_1, @field_name_2
  WHILE @@FETCH_STATUS = 0
  BEGIN
	select @value1=null, @value2=null,@id=@id+1

	if not(isnull(@table_name,'')='' or isnull(@field_name_1,'')='')
		exec GetDataField_ByMotconsuID @table_name, @field_name_1, @Motconsu_ID,@value1 out

	if not(isnull(@table_name,'')='' or isnull(@field_name_2,'')='')
		exec GetDataField_ByMotconsuID @table_name, @field_name_2, @Motconsu_ID,@value2 out

	insert @tbl	(id, row_num, row_name, value1, value2, table_name, field_name_1, field_name_2) 
		values (@id, @row_num, @label, @value1, @value2, @table_name, @field_name_1, @field_name_2)

    FETCH NEXT FROM cur INTO @row_num, @label, @table_name, @field_name_1, @field_name_2
  END
  close cur
  DEALLOCATE cur


select * from @tbl
