SET DATEFIRST 1
	 declare @date datetime
	 set @date='20110601'

	 SELECT 
	 PL_DAY.PL_DAY_ID, PL_DAY.NAME,pl_agend_id
	 ,PL_DAY.START_TIME, PL_DAY.END_TIME 
	 ,DAY_EVEN, DAY_MONTH, DAY_OF_MONTH, DAY_OF_WEEK, DAY_ORDER, DAY_WEEK, DAY_WEEK_MONTH, DAY_YEAR
	 ,PERIOD_FROM, PERIOD_TO
	 ,DUREE_TRANCHE 
	 FROM pl_day 
	 WHERE 
	 PL_DAY.ENABLED=1 
	 --and pl_agend_id in (437) 
	 and (PERIOD_FROM is null or PERIOD_FROM <= @date)						/* День активен с */
	 and (PERIOD_TO is null or PERIOD_TO >= @date)							/* День активен по */
	 and (isnull(DAY_MONTH,0)=0 or DAY_MONTH=month(@date))							/* Месяц */
	 and (isnull(DAY_MONTH,0)=0 or DAY_MONTH=month(@date))
	 and (isnull(DAY_OF_MONTH,0)=0 or DAY_OF_MONTH = day(@date))					/* День месяца */
	 and (isnull(DAY_YEAR,0)=0 or DAY_YEAR = (year(@date)-1995)/* magic year*/)		/* Год */
	 and (isnull(DAY_EVEN,0)=0 or DAY_EVEN=(day(@date)& 1 + 1))						/* Признак четности, нечетный 2, четный 1 */
	 and (isnull(DAY_WEEK,0)=0 or DAY_WEEK=(
		 DATEPART(week,@date)-DATEPART(week,DATEADD(day,1-day(@date),@date))+1))		/* Номер недели в месяце */
	 and (isnull(DAY_OF_WEEK,0)=0 
			or (DAY_OF_WEEK=DATEPART(weekday,@date) and isnull(DAY_WEEK_MONTH,0)=0)	/* Номер дня в неделе */
			or (DAY_OF_WEEK=DATEPART(weekday,@date) and DAY_WEEK_MONTH=DATEDIFF(day,DATEADD(day,1-day(@date),@date),@date)/7+1))
					/* i-тый день недели в месяце */
	 and (case when(isnull(INTERVAL_WORK,0)=0 and isnull(INTERVAL_OFF,0)=0) then 1 else (
			case when (DATEDIFF(day,INTERVAL_STARTFROM,@date))%(INTERVAL_WORK+INTERVAL_OFF)<=(INTERVAL_WORK-1)then 1 else 0 end
		 ) end)=1
	 ORDER BY pl_agend_id,day_order
	