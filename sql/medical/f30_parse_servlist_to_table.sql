
CREATE FUNCTION [dbo].[servlist_to_table](@String varchar(max))       
returns @tbl TABLE (string varchar(64),input varchar(64),start_str varchar(64),end_str varchar(64))      
as       
begin       

declare @input varchar(max)

declare @val varchar(64)
		,@pos int
		,@start_int int
		,@end_int int
		,@start_char varchar(64)
		,@end_char varchar(64)


DECLARE cur CURSOR FOR
select items from dbo.strSplit(@string,',')

OPEN Cur;
FETCH NEXT FROM Cur into @input
WHILE @@FETCH_STATUS = 0
   BEGIN
		select @pos=charindex('-', @input)

		if (@pos>0)     
		begin
		/* услуги подряд */
			select @start_char=substring(@input,1,@pos-1)
				,@end_char=substring(@input,@pos+1,len(@input)-@pos)

			if(@start_char not like '%[^0-9]%' and len(@start_char)>0
			 and @end_char not like '%[^0-9]%' and len(@end_char)>0)
			begin
			/* целые числа*/
				select @start_int=convert(int,@start_char)
						,@end_int=convert(int,@end_char)

				set @pos=@start_int
				while (@pos<= @end_int)
				begin
					insert into @tbl  values (@pos,@input,@start_char,@end_char)
					select @pos=@pos+1			
				end
			end
			else
			begin
			/*не числа */
				insert into @tbl  values (@start_char,@input,@start_char,@end_char)
				insert into @tbl  values (@end_char,@input,@start_char,@end_char)
			end
		end
		else
		begin
		/* одна услуга */
		insert into @tbl  values (@input,@input,@input,@input)
		end
	  FETCH NEXT FROM Cur into @input;
   END;
CLOSE Cur;
DEALLOCATE Cur;

return       
end  