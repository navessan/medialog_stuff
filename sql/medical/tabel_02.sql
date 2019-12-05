declare
    @PL_SUBJ_ID int,
    @PL_AGEND_ID int,
    @PL_DAY_ID int,
    @Date_start datetime,
    @Date_end datetime,
    @Date datetime,
    @new_ID int 


/*
--drop table US_PL_TABEL_REPORT
create table US_PL_TABEL_REPORT(US_PL_TABEL_REPORT_ID int not null
		,date datetime,
        PL_SUBJ_ID int,
        PL_AGEND_ID int,
        PL_DAY_ID int, 
        START_TIME int, 
        END_TIME int,
        START_d datetime, 
        END_d datetime,
        EXCL_d datetime,
        active int,
        session_id int,      
 CONSTRAINT [PK_PL_TABEL_REPORT] PRIMARY KEY CLUSTERED 
(
	[US_PL_TABEL_REPORT_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
*/
    
select @PL_SUBJ_ID=1,        --расписание
        @Date_start='20160901',
        @Date_end='20160902'

truncate table US_PL_TABEL_REPORT

DECLARE cur CURSOR 
   LOCAL           -- LOCAL or GLOBAL
   FORWARD_ONLY    -- FORWARD_ONLY or SCROLL
   STATIC          -- STATIC, KEYSET, DYNAMIC, or FAST_FORWARD
   READ_ONLY       -- READ_ONLY, SCROLL_LOCKS, or OPTIMISTIC
   TYPE_WARNING    -- Inform me of implicit conversions
FOR
-----------------------
select PL_SUBJ_ID
from PL_SUBJ
where isnull(PL_SUBJ.ARCHIVE,0)=0 
and PL_SUBJ_ID in(@PL_SUBJ_ID)
-------------------------------
OPEN Cur;
FETCH NEXT FROM Cur into @PL_SUBJ_ID;
WHILE @@FETCH_STATUS = 0
	BEGIN

	select @Date=@Date_start

	WHILE @Date <=  @Date_end
	BEGIN
		exec up_get_id  @KeyName = 'US_PL_TABEL_REPORT', @Shift = 1, @ID = @new_ID output
		insert into US_PL_TABEL_REPORT (US_PL_TABEL_REPORT_ID, date, PL_SUBJ_ID, PL_AGEND_ID) 
			values (@new_ID,@Date, @PL_SUBJ_ID, [dbo].[pl_GetSubjAgenda]( @PL_SUBJ_ID, @Date ) )
		select @Date=DATEADD(dd,1,@Date)
		CONTINUE
	END
	---------------------------------
	FETCH NEXT FROM Cur into @PL_SUBJ_ID;
	END;
CLOSE Cur;
DEALLOCATE Cur;




update US_PL_TABEL_REPORT set
    PL_DAY_ID=[dbo].[pl_GetPlDay] (PL_AGEND_ID, Date, @PL_SUBJ_ID)

update US_PL_TABEL_REPORT set
    START_TIME=PL_DAY.START_TIME,
    END_TIME=PL_DAY.END_TIME,

    START_D=DateAdd( Hour, PL_DAY.START_TIME /100, date) 
                + DateAdd( minute, PL_DAY.START_TIME %100, 0),
    END_D=DateAdd( Hour, PL_DAY.END_TIME /100, date) 
                + DateAdd( minute, PL_DAY.END_TIME %100, 0),
    active=PL_DAY.ENABLED

from US_PL_TABEL_REPORT tabel
left join PL_DAY on PL_DAY.PL_DAY_ID=tabel.PL_DAY_ID

update US_PL_TABEL_REPORT set
work_plan_d=case when active=1 then end_d-start_d else null end

select
PL_SUBJ.NAME
,case when active=1 then end_d-start_d else null end as day_hours
,(/*события на весь день */
select top 1
max(TO_TIME)
from PL_EXCL as ex 
where ex.PL_SUBJ_ID=t.PL_SUBJ_ID and 
ex.FROM_DATE<=t.date and
ex.TO_DATE>=t.date and
(ex.USE_TIME=0 or
ex.FROM_TIME<t.START_TIME and
ex.TO_TIME>t.END_TIME)
)ex_all_day
,( /*события перед началом рабочего времени*/
select top 1
max(TO_TIME)
from PL_EXCL as ex 
where ex.PL_SUBJ_ID=t.PL_SUBJ_ID and 
ex.USE_TIME=1 and
ex.FROM_DATE<=t.date and
ex.TO_DATE>=t.date and
ex.FROM_TIME<t.START_TIME and
ex.TO_TIME>t.START_TIME
)ex_front_time

,( /*события внутри рабочего времени*/
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
)ex_internal_minutes
,( /*события в конце рабочего времени*/
select top 1
min(FROM_TIME)
from PL_EXCL as ex 
where ex.PL_SUBJ_ID=t.PL_SUBJ_ID and 
ex.USE_TIME=1 and
ex.FROM_DATE<=t.date and
ex.TO_DATE>=t.date and
ex.FROM_TIME<t.END_TIME and
ex.TO_TIME>t.END_TIME
)ex_end_time

,t.*
 from US_PL_TABEL_REPORT as t
 join PL_SUBJ on t.PL_SUBJ_ID=PL_SUBJ.PL_SUBJ_ID
 
 
 