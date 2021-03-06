

alter  function [dbo].[PatientGetPLDog] (@patients_id int, @info varchar(16))
returns varchar(255)
AS
BEGIN
	declare @res as varchar(255)
	declare @nomer varchar(64)

	set @res=''

	if(@patients_id is null)
		return null

	select @res=isnull(nomer_platnogo_dogovora,'')
	from data126 
	where patients_id=@patients_id

	if(@info='nomer' or isnull(@info,'')='')
		return @res
	

	declare @date_from as datetime    
	declare @date_to as datetime
			,@fm_clink_id int
			,@police varchar(32) 

	set @fm_clink_id=3795	--id платного договора

	select @date_from=date_from
			,@date_to=date_to
			,@police=police
	from  FM_CLINK_PATIENTS
	where 
		patients_id=@patients_id
		and fm_clink_id=@fm_clink_id 
		and (date_cancel is null or date_cancel> getdate())
		and (date_to is null or date_to> getdate())

	if(@info='date_from' and @date_from is not null)
		set @res=right('0' + rtrim(day(@date_from)),2) + '.' 
				+right('0' + rtrim(month(@date_from)),2) + '.'
				+rtrim(year(@date_from))

	if(@info='all_vts' and len(@res)>0)
	begin
		set @res= 'Приложение к договору '+ @res +
		+' от '
		+right('0' + rtrim(day(@date_from)),2) + '.' 
		+right('0' + rtrim(month(@date_from)),2) + '.'
		+rtrim(year(@date_from))
	end

	set @res=rtrim(ltrim(@res))

  return @res
END
