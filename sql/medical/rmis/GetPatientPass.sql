
CREATE  function [dbo].[PatientParsePass] (@SERIQ_NOMER_PASPORTA as varchar(100), @sn varchar(1))
returns varchar(6)
AS
BEGIN
	declare @res as varchar(6)
	declare @SERIQ as varchar(100)
	declare @NOMER as varchar(100)

	set @res=null
	set @SERIQ=null
	set @NOMER=null

	set @SERIQ_NOMER_PASPORTA=replace(@SERIQ_NOMER_PASPORTA,' ','')
	set @SERIQ_NOMER_PASPORTA=replace(@SERIQ_NOMER_PASPORTA,'-','')
	
	set @SERIQ=substring(@SERIQ_NOMER_PASPORTA,1,4)
	set @NOMER=substring(@SERIQ_NOMER_PASPORTA,5,6)

	if(@SERIQ not like '%[^0-9]%' and @NOMER not like '%[^0-9]%')
	begin
		if(@sn='s')
			set @res=@SERIQ
		else
			set @res=@NOMER
	end
	else
			set @res=null
  return @res
END
