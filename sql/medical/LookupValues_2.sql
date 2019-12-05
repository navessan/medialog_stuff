
alter function [dbo].[us_LookupValue] (
	@TABLE_NAME varchar(32)
	,@FIELD_NAME varchar(32)
	,@LangCode varchar(10)
	,@find int
)
returns varchar(255)
as

begin
	declare 
		@custom varchar(max)
		,@keys varchar(max)
		,@values varchar(max)
		,@id varchar(255)
		,@val varchar(255)
		,@pos int
		,@delim_len int
		,@ret varchar(255)
		
	declare	@tbl table(
			rec_no int IDENTITY(1, 1) NOT NULL,                  
			id  int NOT NULL,
			value varchar(255)
			)

	select top 1
	@custom=CUSTOM
	from METAFIELD
	where TABLE_NAME=@TABLE_NAME
	and FIELD_NAME=@FIELD_NAME

	--select @custom
	if LEN(isnull(@custom,''))=0
	begin
		return null		
	end

	select @keys=VALUE
	from [dbo].[ftCustomParamsList](@CUSTOM, @LangCode)
	where PARAM_NAME='LookupKeys'

	select @values=VALUE
	from [dbo].[ftCustomParamsList](@CUSTOM, @LangCode)
	where PARAM_NAME='LookupValues'

	--select @keys,@values	
	
	if(LEN(isnull(@keys,''))=0 or LEN(isnull(@values,''))=0 )
		return null	

	DECLARE cur CURSOR 
	   LOCAL           -- LOCAL or GLOBAL
	   FORWARD_ONLY    -- FORWARD_ONLY or SCROLL
	   STATIC          -- STATIC, KEYSET, DYNAMIC, or FAST_FORWARD
	   READ_ONLY       -- READ_ONLY, SCROLL_LOCKS, or OPTIMISTIC
	   TYPE_WARNING    -- Inform me of implicit conversions
	FOR
	---
	select
	id
	from dbo.ids_to_table(@keys)
	order by REC_NO
	----

	OPEN Cur;
	FETCH NEXT FROM Cur into 
			@id
	WHILE @@FETCH_STATUS = 0
		BEGIN
		---------------------------------
		select @pos=CHARINDEX('","',@values,1)
		if @pos=0
			begin
				select @pos=CHARINDEX('", "',@values,1)
					,@delim_len=3				
			end
		else
			select @delim_len=2
		--select @pos as pos
		if(@pos>0)
			begin
				select @val=SUBSTRING(@values,1,@pos)
				select @values=SUBSTRING(@values,@pos+@delim_len,LEN(@values))
			end
		else
			select @val=@values
			
		select @val=REPLACE(@val,'"','')
		
		insert into @tbl (id,value) 
			values(@id,@val)
		---------------------------------
			FETCH NEXT FROM Cur into 
			@id;
		END;
	CLOSE Cur;
	DEALLOCATE Cur;


	select @ret=value from @tbl
	where id=@find
		
	return @ret
end	