DECLARE 
    @data_ID INT,
    @PATIENTS_ID INT, 
    @N_LINE INT,
    @MEDECINS_ID INT,
	@MOTCONSU_ID INT,
	@INFO varchar(max)

set @PATIENTS_ID=160918
set @MEDECINS_ID=920
set @MOTCONSU_ID=3641247

select @INFO=[dbo].[get_serv_from_motconsu](@MOTCONSU_ID)

SELECT @data_ID=MAX(US_SERV_AGR_ID)
FROM US_SERV_AGR
WHERE 
MED_ID=@MEDECINS_ID 
AND PAT_ID = @PATIENTS_ID 
AND MOTCONSU_ID=@MOTCONSU_ID


SELECT *
FROM US_SERV_AGR
WHERE 
MED_ID=@MEDECINS_ID 
AND PAT_ID = @PATIENTS_ID 
AND MOTCONSU_ID=@MOTCONSU_ID
/*
if @data_ID is null
begin 

	declare @P1 int
	exec up_get_id  @KeyName = 'US_SERV_AGR', @Shift = 1, @ID = @P1 output

	BEGIN TRAN 

	insert into US_SERV_AGR
	(US_SERV_AGR_ID
	,INCOM_INFO
	,ARCHIVE
	,MED_ID,PAT_ID,MOTCONSU_ID
	)
	values(@P1
	,@INFO
	,0
	,@MEDECINS_ID,@PATIENTS_ID,@MOTCONSU_ID)

	COMMIT TRAN 
end
else 
begin

	declare @old_info int
	
	select @old_info=datalength(isnull(INCOM_INFO,'')) 
	FROM US_SERV_AGR
	WHERE US_SERV_AGR_ID=@DATA_ID
		
	if(@old_info=0 and @INFO is not null)
		update US_SERV_AGR
		set INCOM_INFO=@INFO
		WHERE US_SERV_AGR_ID=@DATA_ID

end

*/