--база данных
use medialog72_test

declare @date as varchar(32)
--дата отсечки данных
set @date='20130601'

drop table #tables

truncate table KRN_SYS_DELETE_TRACE
truncate table KRN_SYS_ACTION_TRACE
truncate table KRN_SYS_trace
truncate table KRN_SYS_trace_log
truncate table oms_stoplist
truncate table lis_results



create table #tables (tablename varchar(32))
insert into #tables values('FM_PAYMENTS')
insert into #tables values('FM_ACCOUNT_TRAN')
insert into #tables values('FM_BILLDET_PAY')
insert into #tables values('FM_INVOICE')
insert into #tables values('FM_BILLDET')
insert into #tables values('FM_BILL')
insert into #tables values('MOTCONSU')
insert into #tables values('MOTCONSU_XML')
insert into #tables values('PATDIREC')
insert into #tables values('DIR_SERV')
insert into #tables values('DIR_ANSW')
insert into #tables values('FM_CLINK_PATIENTS')
insert into #tables values('FM_CLINK_PATIENTS_ORG')
insert into #tables values('LETTERS')

insert into #tables values('patients')
insert into #tables values('PLANNING')
insert into #tables values('PLANNING_USER_EXT')

insert into #tables values('IMP_FOBOS')
insert into #tables values('IMP_FOBOS_1')
insert into #tables values('IMP_FOLKS_FINISH_M')
insert into #tables values('US_SERV_AGR')

insert into #tables
select table_name from metatable 
where table_name like 'data%'
or table_name like 'US_OMS%'

insert into #tables
select name
from sys.tables
where name like 'cl%'

select tablename from #tables

declare @table as varchar(32)
declare @sql as varchar(512)
declare @sql_1 as varchar(512)
set @sql_1='
alter table _table_ DISABLE TRIGGER ALL
truncate table _table_
/*delete from _table_ where KRN_CREATE_DATE<'''+@date+'''*/
alter table _table_ ENABLE TRIGGER ALL
select count(*) [count in _table_] from _table_
'

DECLARE Cur CURSOR FOR
	select tablename from #tables;

OPEN Cur;
FETCH NEXT FROM Cur into @table;
WHILE @@FETCH_STATUS = 0
   BEGIN
	set @sql=replace(@sql_1, '_table_', @table)
	select @sql
	exec(@sql)
      FETCH NEXT FROM Cur into @table;
   END;
CLOSE Cur;
DEALLOCATE Cur;

drop table #tables
/*
alter table PLANNING DISABLE TRIGGER ALL
delete from PLANNING where KRN_CREATE_DATE<@date
alter table PLANNING ENABLE TRIGGER ALL

alter table PLANNING_USER_EXT DISABLE TRIGGER ALL
delete from PLANNING_USER_EXT where KRN_CREATE_DATE<@date
alter table PLANNING_USER_EXT ENABLE TRIGGER ALL

alter table patients DISABLE TRIGGER ALL
delete from patients
where patients_id not in
(
select patients_id from planning
where patients_id is not null
)
alter table patients ENABLE TRIGGER ALL

*/