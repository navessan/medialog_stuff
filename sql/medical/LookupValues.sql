declare
	@TABLE_NAME varchar(16)
	,@FIELD_NAME varchar(16)
	,@LangCode varchar(10)

declare @custom varchar(max)
	,@keys varchar(max)
	,@values varchar(max)
	,@rec_no int
	,@id varchar(255)
	,@val varchar(255)
	,@pos int
	
declare	@tbl table(
		rec_no int IDENTITY(1, 1) NOT NULL,                  
		id  int NOT NULL,
		value varchar(255)
		)

set @LangCode='rus'

select top 1
@custom=CUSTOM
from METAFIELD
where TABLE_NAME='calls'
and FIELD_NAME='CALL_TYPE'

--select @custom
if LEN(@custom)=0
begin
	select ''
	
end

select @keys=VALUE
from [dbo].[ftCustomParamsList](@CUSTOM, @LangCode)
where PARAM_NAME='LookupKeys'

select @values=VALUE
from [dbo].[ftCustomParamsList](@CUSTOM, @LangCode)
where PARAM_NAME='LookupValues'


select @keys,@values	

DECLARE cur CURSOR 
   LOCAL           -- LOCAL or GLOBAL
   FORWARD_ONLY    -- FORWARD_ONLY or SCROLL
   STATIC          -- STATIC, KEYSET, DYNAMIC, or FAST_FORWARD
   READ_ONLY       -- READ_ONLY, SCROLL_LOCKS, or OPTIMISTIC
   TYPE_WARNING    -- Inform me of implicit conversions
FOR
---
select
*
from dbo.ids_to_table(@keys)
----

OPEN Cur;
FETCH NEXT FROM Cur into 
		@rec_no,@id
WHILE @@FETCH_STATUS = 0
	BEGIN
	---------------------------------
	select @pos=CHARINDEX('","',@values,1)
	if(@pos>0)
		begin
			select @val=SUBSTRING(@values,1,@pos)
			select @values=SUBSTRING(@values,@pos+2,LEN(@values))
		end
	else
		select @val=@values
		
	select @val=REPLACE(@val,'"','')
	
	insert into @tbl
		(@id,@val)
	---------------------------------
		FETCH NEXT FROM Cur into 
		@rec_no,@id;
	END;
CLOSE Cur;
DEALLOCATE Cur;