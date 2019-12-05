declare @PatientID Int, @sn varchar(1)

set @PatientID=160918

	declare @res as varchar(6)
	,@SERIQ_NOMER_PASPORTA as varchar(100)
	,@SERIQ as varchar(100)
	,@NOMER as varchar(100)
	set @res=null
	set @SERIQ_NOMER_PASPORTA=null
	set @SERIQ=null
	set @NOMER=null

	set @SERIQ_NOMER_PASPORTA=(select SERIQ_NOMER_PASPORTA from patients where patients_id=@PatientID)
	--set @SERIQ_NOMER_PASPORTA=''
	set @SERIQ_NOMER_PASPORTA=replace(@SERIQ_NOMER_PASPORTA,' ','')
	set @SERIQ_NOMER_PASPORTA=replace(@SERIQ_NOMER_PASPORTA,'-','')
	
	set @SERIQ=substring(@SERIQ_NOMER_PASPORTA,1,4)
	set @NOMER=substring(@SERIQ_NOMER_PASPORTA,5,6)

if(@SERIQ not like '%[^0-9]%')
	select 'SERIQ ok'

if(@NOMER not like '%[^0-9]%')
	select 'NOMER ok'

	if(@SERIQ like '%[0-9]%' and @NOMER like '%[0-9]%')
	begin
		if(@sn='s')
			set @res=@SERIQ
		else
			set @res=@NOMER
	end
	else
			set @res='w'
	

select @SERIQ_NOMER_PASPORTA,@SERIQ,@NOMER, @res