SET DATEFIRST 1
declare @date datetime
set @date='20110806'

	 SELECT 
DATEDIFF(week,DATEADD(day,1-day(@date),@date),@date)+1 week,
	 PL_DAY.PL_DAY_ID, PL_DAY.NAME
	 ,PL_DAY.START_TIME, PL_DAY.END_TIME 
	 ,DAY_EVEN, DAY_MONTH, DAY_OF_MONTH, DAY_OF_WEEK, DAY_ORDER, DAY_WEEK, DAY_WEEK_MONTH, DAY_YEAR
	 ,PERIOD_FROM, PERIOD_TO
	 ,DUREE_TRANCHE 
	 FROM pl_day 
	 WHERE 
	 PL_DAY.ENABLED=1 
	 --and pl_agend_id in (62) 
	 and (PERIOD_FROM is null or PERIOD_FROM <= @date)						/* День активен с */
	 and (PERIOD_TO is null or PERIOD_TO >= @date)							/* День активен по */
	 and (DAY_MONTH !>0 or DAY_MONTH=month(@date))							/* Месяц */
	 and (DAY_OF_MONTH !>0 or DAY_OF_MONTH = day(@date))					/* День месяца */
	 and (DAY_YEAR !>0 or DAY_YEAR = (year(@date)-1995)/* magic year*/)		/* Год */
	 and (DAY_EVEN !>0 or DAY_EVEN=(day(@date)& 1 + 1))						/* Признак четности, нечетный 2, четный 1 */
	 and (DAY_WEEK !>0 or DAY_WEEK=(
		 DATEPART(week,@date)-DATEPART(week,DATEADD(day,1-day(@date),@date))+1))		/* Номер недели в месяце */
	 and (DAY_OF_WEEK !>0 
			or (DAY_OF_WEEK=DATEPART(weekday,@date) and DAY_WEEK_MONTH !>0)	/* Номер дня в неделе */
			or (DAY_OF_WEEK=DATEPART(weekday,@date) and DAY_WEEK_MONTH=DATEDIFF(day,DATEADD(day,1-day(@date),@date),@date)/7+1))
					/* i-тый день недели в месяце */
	 and (case when(INTERVAL_WORK!>0 and INTERVAL_OFF!>0) then 1 else (
			case when (DATEDIFF(day,INTERVAL_STARTFROM,@date))%(INTERVAL_WORK+INTERVAL_OFF)<=(INTERVAL_WORK-1)then 1 else 0 end
		 ) end)=1
 ORDER BY day_order