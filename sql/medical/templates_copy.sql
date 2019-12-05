EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'xp_cmdshell', 1;
GO
RECONFIGURE;
GO
-----------------
set nocount on


declare @src as varchar(128)
		,@dst as varchar(128)
		,@template as varchar(128)
		,@Folder varchar(255)
		
 
DECLARE @CMD NVARCHAR(4000)
select @Folder = 'c:\medialog\SYS\LETTERS\'

select @template='шаблон_мц_низ'


select @src=FileName
from TEMPLATE
where Descriptor like @template
and Template_Parent_ID=0

select @src

-----
/*
select @dst='test.txt'
SET @CMD = 'COPY "' + @folder + @src + '" "' + @Folder + @dst + '"'
select @CMD
exec master..xp_cmdshell @CMD
*/
-----

DECLARE cur CURSOR 
   LOCAL           -- LOCAL or GLOBAL
   FORWARD_ONLY    -- FORWARD_ONLY or SCROLL
   STATIC          -- STATIC, KEYSET, DYNAMIC, or FAST_FORWARD
   READ_ONLY       -- READ_ONLY, SCROLL_LOCKS, or OPTIMISTIC
   TYPE_WARNING    -- Inform me of implicit conversions
FOR
-----------
select
FileName
from TEMPLATE
where Descriptor like @template
and Template_Parent_ID>0
----------

OPEN Cur;
FETCH NEXT FROM Cur into 
		@dst
WHILE @@FETCH_STATUS = 0
	BEGIN
	---------------------------------
	SET @CMD = 'COPY "' + @folder + @src + '" "' + @Folder + @dst + '"'
	select @CMD
	exec master..xp_cmdshell @CMD
	---------------------------------
	FETCH NEXT FROM Cur into 
		@dst
	END;
CLOSE Cur;
DEALLOCATE Cur;	
	
	
----------
EXEC sp_configure 'xp_cmdshell', 0;
GO
RECONFIGURE;
GO
