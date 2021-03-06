USE [medialog7]
GO
/****** Object:  StoredProcedure [dbo].[Alisa_import_labs]    Script Date: 10/14/2013 18:56:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER  PROCEDURE [dbo].[Alisa_import_labs](@count int)
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
,@MEDECINS_ID int
,@FM_DEP_ID int
,@MEDDEP_ID int

select
@MEDECINS_ID=700	-- Врач Лаборатория
,@MODELS_ID=159		-- Тип записи Лаборатория результаты 
,@FM_DEP_ID=15		-- Отделение Лаборатория
,@MEDDEP_ID=746		-- Отделение, привязанное к пользователю
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
declare cur cursor 
   LOCAL           -- LOCAL or GLOBAL
   FORWARD_ONLY    -- FORWARD_ONLY or SCROLL
   STATIC          -- STATIC, KEYSET, DYNAMIC, or FAST_FORWARD
   READ_ONLY       -- READ_ONLY, SCROLL_LOCKS, or OPTIMISTIC
   TYPE_WARNING    -- Inform me of implicit conversions
for
---------------
SELECT distinct 
TOP (@count)
 LIS_RESULTS.PATDIREC_ID
--,DIR_ANSW.DIR_ANSW_ID
--,LIS_RESULTS.TST_Date
,dateadd(day,0,DATEDIFF(day, 0, LIS_RESULTS.TST_Date))
,PATIENTS.PATIENTS_ID
 --,MOTCONSU.MOTCONSU_ID,MOTCONSU.DATE_CONSULTATION
FROM
LIS_RESULTS LIS_RESULTS with(nolock)
 JOIN PATIENTS PATIENTS with(nolock) ON (LIS_RESULTS.PATIENTS_ID= cast( PATIENTS.PATIENTS_ID as varchar(32)))
LEFT OUTER JOIN DIR_ANSW DIR_ANSW ON LIS_RESULTS.PATDIREC_ID= DIR_ANSW.PATDIREC_ID 
LEFT OUTER JOIN PATDIREC PATDIREC ON LIS_RESULTS.PATDIREC_ID= PATDIREC.PATDIREC_ID 
left JOIN MOTCONSU MOTCONSU with(nolock) ON 
(PATIENTS.PATIENTS_ID= MOTCONSU.PATIENTS_ID 
	and DATEDIFF(day, 0, LIS_RESULTS.TST_Date)= DATEDIFF(day, 0, MOTCONSU.DATE_CONSULTATION) 
	and MOTCONSU.MEDECINS_ID=@MEDECINS_ID
	and MOTCONSU.FM_DEP_ID=@FM_DEP_ID
	and MOTCONSU.MODELS_ID in(@MODELS_ID)
)
WHERE 
( /* результат вне направления и без конечной записи */
(isnull(LIS_RESULTS.PATDIREC_ID,0)=0 and MOTCONSU.MOTCONSU_ID is null) or
/* результат по направлению без ответа */
(isnull(LIS_RESULTS.PATDIREC_ID,0)>0  and DIR_ANSW.DIR_ANSW_ID is null) or
/* результат по направлению, направления не существует */
(isnull(LIS_RESULTS.PATDIREC_ID,0)>0 and PATDIREC.PATDIREC_ID is null)
--or (1=1)
)
--and 
--PATIENTS.PATIENTS_ID=@PATIENTS_ID
--and LIS_RESULTS.TST_Date>'2013-10-09 00:00:00.000'
--order by dateadd(day,0,DATEDIFF(day, 0, LIS_RESULTS.TST_Date))
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
