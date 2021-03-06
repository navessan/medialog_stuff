
create  PROCEDURE [dbo].[Alisa_import_labs](@count int)
AS
BEGIN


--DECLARE @count int
if (@count is null) 
	SET @count = 20

set nocount on

declare @MOTCONSU_ID int
,@MODELS_ID int
,@PATIENTS_ID int
,@PATDIREC_ID int
,@DATE_CONSULTATION datetime


select
@MODELS_ID=159		-- Тип записи Лаборатория результаты 
--,@PATIENTS_ID=660578	-- Шулятикова :)
--@PATIENTS_ID=160918	-- Тест тест
--,@DATE_CONSULTATION=GetDate()
--,@PATDIREC_ID=688022
-----------------
/*	

exec [dbo].[Alisa_new_motconsu_record] @PATIENTS_ID, @DATE_CONSULTATION, @PATDIREC_ID, @MOTCONSU_ID out
	select @MOTCONSU_ID MOTCONSU_ID, @PATDIREC_ID PATDIREC_ID, @DATE_CONSULTATION DATE_CONSULTATION, @PATIENTS_ID PATIENTS_ID
----------------
*/
declare cur cursor local forward_only for
---------------
SELECT distinct 
TOP (@count)
 LIS_RESULTS.PATDIREC_ID
--,LIS_RESULTS.TST_Date
,dateadd(day,0,DATEDIFF(day, 0, LIS_RESULTS.TST_Date))
,PATIENTS.PATIENTS_ID
 --,MOTCONSU.MOTCONSU_ID,MOTCONSU.DATE_CONSULTATION
FROM
LIS_RESULTS LIS_RESULTS 
 JOIN PATIENTS PATIENTS ON (LIS_RESULTS.PATIENTS_ID= cast( PATIENTS.PATIENTS_ID as varchar(32)))
 left JOIN MOTCONSU MOTCONSU ON 
(PATIENTS.PATIENTS_ID= MOTCONSU.PATIENTS_ID 
	and DATEDIFF(day, 0, LIS_RESULTS.TST_Date)= DATEDIFF(day, 0, MOTCONSU.DATE_CONSULTATION) 
	and MOTCONSU.MODELS_ID in(@MODELS_ID))
WHERE
MOTCONSU.MOTCONSU_ID is null
--and PATIENTS.PATIENTS_ID=@PATIENTS_ID
order by dateadd(day,0,DATEDIFF(day, 0, LIS_RESULTS.TST_Date))
-----------
  open cur
  FETCH NEXT FROM cur INTO @PATDIREC_ID, @DATE_CONSULTATION, @PATIENTS_ID
  WHILE @@FETCH_STATUS = 0
  BEGIN

	exec [dbo].[Alisa_new_motconsu_record] @PATIENTS_ID, @DATE_CONSULTATION, @PATDIREC_ID, @MOTCONSU_ID out

	select @MOTCONSU_ID MOTCONSU_ID, @PATDIREC_ID PATDIREC_ID, @DATE_CONSULTATION DATE_CONSULTATION, @PATIENTS_ID PATIENTS_ID

    FETCH NEXT FROM cur INTO @PATDIREC_ID, @DATE_CONSULTATION, @PATIENTS_ID
  END
  close cur
  DEALLOCATE cur

-- end of procedure
END
