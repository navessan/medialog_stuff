declare @period datetime
	,@fm_clink_id int
	,@LAST_MOTCONSU_ID int
	,@MOTCONSU_EV_ID int

select @period = {ts '2015-05-01 00:00:00.000'}
	,@FM_CLINK_ID=3041

DECLARE cur CURSOR FOR
------
SELECT 
MOTCONSU_EV_ID
,(select top 1 MOTCONSU_ID
	from motconsu sub 
	where sub.MOTCONSU_EV_ID= MOTCONSU.MOTCONSU_ID
	  order by sub.DATE_CONSULTATION desc
) last_ID
--, ev_name
--,*
FROM MOTCONSU
WHERE
    MOTCONSU.DATE_CONSULTATION>= DATEADD(month, DATEDIFF(month, 0, @period), 0)  
and MOTCONSU.DATE_CONSULTATION< DATEADD(month, DATEDIFF(month, 0, @period)+1, 0)  
and MOTCONSU_EV_ID=MOTCONSU_ID
and isnull(EV_CLOSE,0)=0 
and isnull(MOTCONSU_EVENT_TYPES_ID,0) not in (3,4) /* disp, prof302 */
-----

OPEN Cur;
FETCH NEXT FROM Cur into @MOTCONSU_EV_ID, @LAST_MOTCONSU_ID;
WHILE @@FETCH_STATUS = 0
   BEGIN
--------------------------
select @MOTCONSU_EV_ID
	  ,@LAST_MOTCONSU_ID
/*
update ev_close set
ev_close.ZAPIS_ZAKR_VAYHAQ_SOB_TIE=1
from motconsu ev_close
where
ev_close.motconsu_id=@LAST_MOTCONSU_ID

update ev_open set
ev_open.EV_CLOSE=1,
ev_open.EV_DATE_CLOSE=getdate(),
ev_open.DATA_ZAKR_TIQ_SLUHAQ_OBRA=getdate()
from motconsu ev_open 
where
motconsu_id=@MOTCONSU_EV_ID
*/
--------------------------
      FETCH NEXT FROM Cur into @MOTCONSU_EV_ID, @LAST_MOTCONSU_ID;
   END;
CLOSE Cur;
DEALLOCATE Cur;
