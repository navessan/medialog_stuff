--база данных
use medialog7_back

declare @date as varchar(32)
--дата отсечки данных
set @date='20130101'

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

insert into #tables
select table_name from metatable 
where table_name like 'planning%'

select tablename from #tables

declare @table as varchar(32)
declare @sql as varchar(512)
declare @sql_1 as varchar(512)
set @sql_1='
alter table _table_ DISABLE TRIGGER ALL
delete from _table_ where KRN_CREATE_DATE<'''+@date+'''
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

truncate table KRN_SYS_DELETE_TRACE
truncate table KRN_SYS_trace
truncate table KRN_SYS_trace_log
truncate table oms_stoplist