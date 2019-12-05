declare @SubjID int, @DatePlan datetime
set @SubjID=326 
set @DatePlan='20110620'

select dbo.pl_GetSubjAgenda (@SubjID, @DatePlan ) pl_agend_id;

 exec dbo.pl_GetMedecinGrid @SubjID, @DatePlan,0