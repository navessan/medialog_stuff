

CREATE FUNCTION [dbo].[pl_GetPlDay_rzd] (@AgendaID Int, @Date DateTime/*, @PlanSubjID int*/ )  
RETURNS Integer AS  
BEGIN 
  DECLARE 
    @Res int,
    @status int

   SET DATEFIRST 1

	 SELECT 
		@Res=case when PL_DAY.ENABLED=1 then PL_DAY.PL_DAY_ID else null end
	 FROM pl_day 
	 WHERE 
	 --PL_DAY.ENABLED=1 
	--and isnull(PL_SUBJ_ID, @PlanSubjID) = @PlanSubjID		/* i dont know for what it is */
	 pl_agend_id in (@AgendaID) 
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
	 and (case when((INTERVAL_WORK is null or INTERVAL_WORK!>0) and (INTERVAL_OFF is null or INTERVAL_OFF!>0)) then 1 else (
			case when (DATEDIFF(day,INTERVAL_STARTFROM,@date))%(INTERVAL_WORK+INTERVAL_OFF)<=(INTERVAL_WORK-1)then 1 else 0 end
		 ) end)=1
	 ORDER BY day_order

    
  RETURN( @Res );
END
