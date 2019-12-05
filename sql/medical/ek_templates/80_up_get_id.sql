declare @P1 int


exec up_get_id  @KeyName = 'PATDIREC_DRUGS', @Shift = 1, @ID = @P1 output
select @P1 Result


exec up_get_id  @KeyName = 'PATDIREC_DRUGS_DET', @Shift = 1, @ID = @P1 output
select @P1 Result
