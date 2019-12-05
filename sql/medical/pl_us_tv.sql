CREATE function [dbo].[pl_us_tv] (@DAY_DATE DateTime, @place varchar(32))
RETURNS @table TABLE (
		DAY_DATE datetime,
        PL_SUBJ_ID int,
        PL_AGEND_ID int,
        PL_DAY_ID int, 
        START_TIME int, 
        END_TIME int,
        START_d datetime, 
        END_d datetime,
        EXCL_TIME int,
        active int,
        SubjName varchar(100),
        SpecializationID int,
        Specialization varchar(100),
        Cabinet varchar(100),
        CabinetDay varchar(100),
        Comments varchar(100),
		CntFreeTimeSlots int)
as
begin

declare
    @PL_SUBJ_ID int,
    @PL_AGEND_ID int,
    @PL_DAY_ID int

--отрезаем время
--select @DAY_DATE=DATEADD(d,datediff(d,0,@DAY_DATE),0)       

insert into @table (DAY_DATE, PL_SUBJ_ID, SubjName, SpecializationID, Specialization, Cabinet) 
-----------------------
  select distinct 
  DATEADD(d,datediff(d,0,@DAY_DATE),0),
  pl.pl_subj_id, pl.NAME, spec.SPECIALISATION_ID, spec.NAME, dbo.ParseLangString(PL_CABINETS.NAME,'rus')
  --pl.LIEU
  from pl_subj_param sp
  inner join pl_subj pl  on sp.pl_subj_id = pl.pl_subj_id
  left outer join SPECIALISATION spec on spec.SPECIALISATION_ID = pl.SPECIALISATION_ID
  LEFT OUTER JOIN PL_CABINETS PL_CABINETS ON PL_CABINETS.PL_CABINETS_ID = PL.PL_CABINETS_ID 
  where 
  isnull(pl.ARCHIVE, 0) = 0  
--and dbo.ParseLangString(PL_CABINETS.NAME,'rus')=@place
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

--удаление записей, не входящих в заданное время
delete from @table
where START_d>@DAY_DATE or END_d<@DAY_DATE

--поиск кабинета для планового дня
update @table set
    CabinetDay=dbo.ParseLangString(PL_CABINETS.NAME,'rus')
from @table t
join PL_CABINETS_DAYS on t.PL_DAY_ID = PL_CABINETS_DAYS.PL_DAY_ID and t.PL_SUBJ_ID = PL_CABINETS_DAYS.PL_SUBJ_ID 
JOIN PL_CABINETS PL_CABINETS ON PL_CABINETS.PL_CABINETS_ID = PL_CABINETS_DAYS.PL_CABINETS_ID 
--------
/*
оставляем только одну запись с заполненным кабинетом
кабинет из дня приоритетнее дня по умолчанию из расписания
*/
delete 
from @table
where 
PL_SUBJ_ID not in(
	select top 1 PL_SUBJ_ID from @table
	where isnull(CabinetDay,'')=@place
	or (isnull(Cabinet,'')=@place and CabinetDay is null)
	order by CabinetDay desc, Cabinet desc
)


--поиск исключительных событий
update @table set
EXCL_TIME=(/*события на весь день */
select top 1
max(TO_TIME)
from PL_EXCL as ex 
where ex.PL_SUBJ_ID=t.PL_SUBJ_ID and 
ex.FROM_DATE<=t.DAY_DATE and
ex.TO_DATE>=t.DAY_DATE and
(ex.USE_TIME=0 or
ex.FROM_TIME<=t.START_TIME and
ex.TO_TIME>=t.END_TIME)
)
from @table as t

delete 
from @table
where EXCL_TIME>0

/*
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
--считает неправильно???
update @table set
CntFreeTimeSlots =(select count(*)
		  from dbo.pl_GetMedecinGridFunc2(PL_SUBJ_ID, DAY_DATE, DAY_DATE, 0)
		  )


return
--------
end

