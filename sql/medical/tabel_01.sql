declare
    @PL_SUBJ_ID int,
    @PL_AGEND_ID int,
    @PL_DAY_ID int,
    @Date_start datetime,
    @Date_end datetime,
    @Date datetime
    
select @PL_SUBJ_ID=41,        --расписание
        @Date_start='20160801',
        @Date_end='20160831'


declare @tbl table(date datetime,
        PL_AGEND_ID int,
        PL_DAY_ID int, 
        START_TIME int, 
        END_TIME int,
        START_d datetime, 
        END_d datetime,
        active int
)

SET DATEFIRST 1

select @Date=@Date_start

WHILE @Date <=  @Date_end
BEGIN

    insert into @tbl (date,PL_AGEND_ID) values (@Date, [dbo].[pl_GetSubjAgenda]( @PL_SUBJ_ID, @Date ) )
   select @Date=DATEADD(dd,1,@Date)
   CONTINUE
END

update @tbl set
    PL_DAY_ID=[dbo].[pl_GetPlDay] (PL_AGEND_ID, Date, @PL_SUBJ_ID)

update @tbl set
    tabel.START_TIME=PL_DAY.START_TIME,
    tabel.END_TIME=PL_DAY.END_TIME,

    tabel.START_D=DateAdd( Hour, PL_DAY.START_TIME /100, date) 
                + DateAdd( minute, PL_DAY.START_TIME %100, 0),
    tabel.END_D=DateAdd( Hour, PL_DAY.END_TIME /100, date) 
                + DateAdd( minute, PL_DAY.END_TIME %100, 0),
    tabel.active=PL_DAY.ENABLED

from @tbl tabel
left join PL_DAY on PL_DAY.PL_DAY_ID=tabel.PL_DAY_ID


select *
,case when active=1 then end_d-start_d else null end
day_hours
 from @tbl 