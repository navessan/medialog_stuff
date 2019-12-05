SET DATEFIRST 1
declare @date datetime
set @date='20110531'

	 SELECT 
	 PL_DAY.PL_DAY_ID, PL_DAY.NAME
,INTERVAL_STARTFROM
,INTERVAL_WORK
,INTERVAL_OFF
,(INTERVAL_WORK+INTERVAL_OFF) intsum
,case when(INTERVAL_STARTFROM>'') then DATEDIFF(day,INTERVAL_STARTFROM,@date) end diff
,case when(INTERVAL_WORK>0 and INTERVAL_OFF>0)then
DATEDIFF(day,INTERVAL_STARTFROM,@date)%(INTERVAL_WORK+INTERVAL_OFF) end diff1
	 ,PL_DAY.START_TIME, PL_DAY.END_TIME 
	 ,DAY_EVEN, DAY_MONTH, DAY_OF_MONTH, DAY_OF_WEEK, DAY_ORDER, DAY_WEEK, DAY_WEEK_MONTH, DAY_YEAR
	 ,PERIOD_FROM, PERIOD_TO
	 ,DUREE_TRANCHE 
	 FROM pl_day 
	 WHERE 
	 PL_DAY.ENABLED=1 
	 --and pl_agend_id in (62) 
	 and (DAY_WEEK !>0 or DAY_WEEK=(
		 DATEPART(week,@date)-DATEPART(week,DATEADD(day,1-day(@date),@date))+1))		/* Номер недели в месяце */
	 and (DAY_OF_WEEK !>0 
			or (DAY_OF_WEEK=DATEPART(weekday,@date) and DAY_WEEK_MONTH !>0)	/* Номер дня в неделе */
			or (DAY_OF_WEEK=DATEPART(weekday,@date) and DAY_WEEK_MONTH=DATEDIFF(week,DATEADD(day,1-day(@date),@date),@date)+1))
					/* i-тый день недели в месяце */
and (case when(INTERVAL_WORK!>0 and INTERVAL_OFF!>0) then 1 else (
	case when (DATEDIFF(day,INTERVAL_STARTFROM,@date))%(INTERVAL_WORK+INTERVAL_OFF)<=(INTERVAL_WORK-1)then 1 else 0 end
) end)=1
 ORDER BY day_order