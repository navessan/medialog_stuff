
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pl_us_tablo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[pl_us_tablo]

go

create function [dbo].[pl_us_tablo] (@DAY_DATE DateTime, @PlParamID int)
RETURNS @table TABLE (
		DAY_DATE datetime,
        PL_SUBJ_ID int,
        PL_AGEND_ID int,
        PL_DAY_ID int, 
        START_TIME int, 
        END_TIME int,
        START_d datetime, 
        END_d datetime,
        EXCL_d datetime,
        active int,
        SubjName varchar(100),
        SpecializationID int,
        Specialization varchar(100),
        Cabinet varchar(100),
        Comments varchar(100),
		CntFreeTimeSlots int)
as
begin

declare
    @PL_SUBJ_ID int,
    @PL_AGEND_ID int,
    @PL_DAY_ID int

insert into @table (DAY_DATE, PL_SUBJ_ID, SubjName,SpecializationID, Specialization, Cabinet) 
-----------------------
  select distinct 
  @DAY_DATE,
  pl.pl_subj_id, pl.NAME, spec.SPECIALISATION_ID, spec.NAME, pl.LIEU
  from pl_subj_param sp
  inner join pl_subj pl  on sp.pl_subj_id = pl.pl_subj_id
  left outer join SPECIALISATION spec on spec.SPECIALISATION_ID = pl.SPECIALISATION_ID
  where 
  isnull(pl.ARCHIVE, 0) = 0 and 
  (sp.pl_param_id = @PlParamID or isnull(@PlParamID, 0) = 0) 
  -- Здесь можно наложить любое условие по набору расписаний, которые должны попадать в сетку табло
  -- and pl.pl_subj_id in (53, 54)
-------------------------------
update @table set
	PL_AGEND_ID=[dbo].[pl_GetSubjAgenda]( PL_SUBJ_ID, DAY_DATE )

update @table set
    PL_DAY_ID=[dbo].[pl_GetPlDay] (PL_AGEND_ID, DAY_DATE, PL_SUBJ_ID)

--определение времени из типового дня
update @table set
    START_TIME=PL_DAY.START_TIME,
    END_TIME=PL_DAY.END_TIME,

    START_D=DateAdd( Hour, PL_DAY.START_TIME /100, DAY_DATE) 
                + DateAdd( minute, PL_DAY.START_TIME %100, 0),
    END_D=DateAdd( Hour, PL_DAY.END_TIME /100, DAY_DATE) 
                + DateAdd( minute, PL_DAY.END_TIME %100, 0),
    active=PL_DAY.ENABLED

from @table t
left join PL_DAY on PL_DAY.PL_DAY_ID=t.PL_DAY_ID

--удаление неактивных дней
delete from @table
where ISNULL(active,0)=0
/*
--поиск исключительных событий
update @table set
work_plan_d=case when active=1 then end_d-start_d else null end
,ex_all_day=(/*события на весь день */
select top 1
max(TO_TIME)
from PL_EXCL as ex 
where ex.PL_SUBJ_ID=t.PL_SUBJ_ID and 
ex.FROM_DATE<=t.date and
ex.TO_DATE>=t.date and
(ex.USE_TIME=0 or
ex.FROM_TIME<t.START_TIME and
ex.TO_TIME>t.END_TIME)
)
,ex_front_time=( /*события перед началом рабочего времени*/
select top 1
max(TO_TIME)
from PL_EXCL as ex 
where ex.PL_SUBJ_ID=t.PL_SUBJ_ID and 
ex.USE_TIME=1 and
ex.FROM_DATE<=t.date and
ex.TO_DATE>=t.date and
ex.FROM_TIME<t.START_TIME and
ex.TO_TIME>t.START_TIME
)
,ex_internal_minutes=( /*события внутри рабочего времени*/
select
sum(
(TO_TIME/100*60+TO_TIME%100)-(FROM_TIME/100*60+FROM_TIME%100) 
)
from PL_EXCL as ex 
where ex.PL_SUBJ_ID=t.PL_SUBJ_ID and 
ex.USE_TIME=1 and
ex.FROM_DATE<=t.date and
ex.TO_DATE>=t.date and
ex.FROM_TIME>=t.START_TIME and
ex.TO_TIME<=t.END_TIME
)
,ex_end_time=( /*события в конце рабочего времени*/
select top 1
min(FROM_TIME)
from PL_EXCL as ex 
where ex.PL_SUBJ_ID=t.PL_SUBJ_ID and 
ex.USE_TIME=1 and
ex.FROM_DATE<=t.date and
ex.TO_DATE>=t.date and
ex.FROM_TIME<t.END_TIME and
ex.TO_TIME>t.END_TIME
)
from US_PL_TABEL_REPORT as t
*/

--свободные места
update @table set
CntFreeTimeSlots =(select count(*)
		  from dbo.pl_GetMedecinGridFunc2(PL_SUBJ_ID, DAY_DATE, DAY_DATE, 0)
		  )


return
--------
end


-------
go
--GRANT EXECUTE ON [dbo].[US_sp_PL_TABEL_REPORT] TO [public]



