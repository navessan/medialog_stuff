USE [medialog7]
GO
/****** Object:  UserDefinedFunction [dbo].[PatientParsePass]    Script Date: 02/29/2012 14:13:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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

	if(@SERIQ not like '%[^0-9]%' and len(@SERIQ)>0
   and @NOMER not like '%[^0-9]%' and len(@NOMER)>0)
	begin
		if(@sn='s')
			set @res=substring(@SERIQ,1,2)+' '+substring(@SERIQ,3,2)
		else
			set @res=@NOMER
	end
	else
			set @res=null
  return @res
END
