declare @date as varchar(32)
set @date='20111101'

use medialog7_back

declare @table as varchar(32)
declare @sql as varchar(512)
declare @sql_1 as varchar(512)
set @sql_1='
alter table _table_ DISABLE TRIGGER ALL
delete from _table_ where KRN_CREATE_DATE<'''+@date+'''
alter table _table_ ENABLE TRIGGER ALL
select count(*) [count in _table_] from _table_
'
set @table='planning'
set @sql=replace(@sql_1, '_table_', @table)
select @sql
exec(@sql)

--FM_PAYMENTS
set @table='FM_PAYMENTS'
set @sql=replace(@sql_1, '_table_', @table)
select @sql
exec(@sql)

--FM_ACCOUNT_TRAN
set @table='FM_ACCOUNT_TRAN'
set @sql=replace(@sql_1, '_table_', @table)
select @sql
exec(@sql)

--FM_BILLDET_PAY
set @table='FM_BILLDET_PAY'
set @sql=replace(@sql_1, '_table_', @table)
select @sql
exec(@sql)

--FM_INVOICE
set @table='FM_INVOICE'
set @sql=replace(@sql_1, '_table_', @table)
select @sql
exec(@sql)

--FM_BILLDET
set @table='FM_BILLDET'
set @sql=replace(@sql_1, '_table_', @table)
select @sql
exec(@sql)

--FM_BILL
set @table='FM_BILL'
set @sql=replace(@sql_1, '_table_', @table)
select @sql
exec(@sql)

--MOTCONSU
set @table='MOTCONSU'
set @sql=replace(@sql_1, '_table_', @table)
select @sql
exec(@sql)

--PATDIREC
set @table='PATDIREC'
set @sql=replace(@sql_1, '_table_', @table)
select @sql
exec(@sql)

--DIR_SERV
set @table='DIR_SERV'
set @sql=replace(@sql_1, '_table_', @table)
select @sql
exec(@sql)

--DIR_ANSW
set @table='DIR_ANSW'
set @sql=replace(@sql_1, '_table_', @table)
select @sql
exec(@sql)
