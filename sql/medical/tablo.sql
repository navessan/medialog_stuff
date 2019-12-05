USE [medialog]
GO

/****** Object:  UserDefinedFunction [dbo].[pl_GetSubjsGrid]    Script Date: 09/28/2016 14:52:20 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

alter function [dbo].[pl_GetSubjsGrid_tablo] (@DateFrom DateTime, @PlParamID int)
RETURNS @table TABLE (PlSubjID int, SubjName varchar(100), SpecializationID int,
					Specialization varchar(100), Cabinet varchar(100),
					DayDate datetime, TimeBegin datetime, TimeEnd datetime,
					TimeWork varchar(32),
					Comments varchar(100),
					ExclAllDay bit,
					CntFreeTimeSlots int)
AS
BEGIN
  declare @SubjID int, @SubjName varchar(100), @SpecializationID int,
		  @Specialization varchar(100), @Medecin varchar(100), @Cabinet varchar(100),
		  @Comments varchar(100), @excl_name varchar(100), @CntFreeTimeSlots int
		  
  declare @SubjAgenda int, @PlDay int, 
		@day_active bit, @TimeWork varchar(32), @ExclAllDay bit,
		@day_from datetime, @day_to datetime, @d1 datetime, @d2 datetime

  -- Дата должна передаватсья без времени, но на всякий случай отрезаем время
  set @DateFrom = cast(round(cast(@DateFrom as float), 0, 1) as datetime)

  declare plsub_cur cursor LOCAL FORWARD_ONLY FOR
  ------------
  select distinct pl.pl_subj_id, pl.NAME, spec.SPECIALISATION_ID, spec.NAME, pl.LIEU
  from pl_subj_param sp
		inner join pl_subj pl  on sp.pl_subj_id = pl.pl_subj_id
		left outer join SPECIALISATION spec on spec.SPECIALISATION_ID = pl.SPECIALISATION_ID
  where 
  isnull(pl.ARCHIVE, 0) = 0 and 
  (sp.pl_param_id = @PlParamID or isnull(@PlParamID, 0) = 0) 
  -- Здесь можно наложить любое условие по набору расписаний, которые должны попадать в сетку табло
  -- and pl.pl_subj_id in (53, 54)
  ------------

  open plsub_cur
  while 1 > 0
  begin
    fetch next from plsub_cur into @SubjID, @SubjName, @SpecializationID, @Specialization, @Cabinet
    if @@FETCH_STATUS <> 0 break
		--------------------
		select @Comments = ''
			,@CntFreeTimeSlots = 0
			,@day_from=null
			,@day_to=null
			,@day_active=null
			,@ExclAllDay=0
		----------------------
		set @SubjAgenda = dbo.pl_GetSubjAgenda( @SubjID, @DateFrom );
		set @PlDay = dbo.pl_GetPlDay( @SubjAgenda, @DateFrom, @SubjID );

		--определение времени из типового дня
		select
			@day_from=DateAdd( Hour, PL_DAY.START_TIME /100, @DateFrom) 
                + DateAdd( minute, PL_DAY.START_TIME %100, 0),
			@day_to=DateAdd( Hour, PL_DAY.END_TIME /100, @DateFrom) 
                + DateAdd( minute, PL_DAY.END_TIME %100, 0),
			@day_active=PL_DAY.ENABLED
		from PL_DAY 
		where PL_DAY_ID=@PlDay
		----------------------

		if @day_active=1
		begin
		
/*
--поиск плановых событий
select 
@DateFrom +  dbo.pl_fPlanTimeToTime( INT_FROM ) as StartTime
, @DateFrom +  dbo.pl_fPlanTimeToTime( INT_TO ) as EndTime
, PL_LEG.NAME 
from PL_INT 
left outer join pl_leg on pl_leg.pl_leg_id = pl_int.pl_leg_id
where PL_DAY_ID = @PlDay
-------------
*/   
		-- поиск исключительных событий   
		  declare plgrid_cur cursor LOCAL FORWARD_ONLY FOR
			select 
			@DateFrom + dbo.pl_fPlanTimeToTime( From_Time ) StartTime
			,@DateFrom + dbo.pl_fPlanTimeToTime( To_Time ) EndTime
			,name
			from pl_excl where
			FROM_DATE<= @DateFrom and
			TO_DATE >= @DateFrom and 
			PL_SUBJ_ID = @SubjID
		  order by FROM_TIME
		  
		  open plgrid_cur
		  while 1 > 0
		  begin
			fetch next from plgrid_cur into @D1, @D2, @excl_name
			if @@FETCH_STATUS <> 0 break
			
            -- Если искл.событие на весь день, то выводим только его и остальные игнорируем
			if @D1 <= @day_from and @D2 >= @day_to
			begin
				select @Comments = @excl_name
						,@ExclAllDay=1
				break	--выход из курсора plgrid_cur
			end
			else
				set @Comments = @Comments + CHAR(13) + CHAR(10) +
								convert(varchar(5), @D1, 108) + ' - ' + convert(varchar(5), @D2, 108) + ' ' + @excl_name
		  end
		  close plgrid_cur
		  deallocate plgrid_cur

		  set @CntFreeTimeSlots = 0
		  select @CntFreeTimeSlots = count(*)
		  from dbo.pl_GetMedecinGridFunc2(@SubjID, @DateFrom, @DateFrom, 0)
		  where EType = 0
		  
		  -- рабочее время в виде 09:00 - 18:00
		  select @TimeWork=convert(varchar(5), @day_from, 108) + ' - ' + convert(varchar(5), @day_to, 108)
		  
		  if(@ExclAllDay=0)
			insert into @table values (@SubjID, @SubjName, @SpecializationID, @Specialization, @Cabinet,
	 							 @DateFrom, @day_from, @day_to, 
	 							 @TimeWork, @Comments, @ExclAllDay,
	 							 @CntFreeTimeSlots)		  
		
		end --if @day_active=1
    
  end
  close plsub_cur
  deallocate plsub_cur

  RETURN
END

GO


