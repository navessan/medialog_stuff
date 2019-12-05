--база данных
use medialog7_back

declare @new_pat_id int
		,@old_pat_id int
		,@MOTCONSU_ID int
select
	@new_pat_id=0
	,@old_pat_id=0
	,@MOTCONSU_ID=0

IF OBJECT_ID('dbo.#tables', 'U') IS NOT NULL
	drop table #tables

set nocount on

create table #tables (tablename varchar(128))

insert into #tables values('MOTCONSU')
--insert into #tables values('MOTCONSU_FLDR_RECORDS') --что это
--insert into #tables values('MOTCONSU_FLDRS') --что это
insert into #tables values('MOTCONSU_XML')
insert into #tables values('MOTCONSU_XML_HISTORY')
insert into #tables values('PATDIREC')

--добавляем таблицы всякие типа DATA_что-то-там
insert into #tables
select T.TABLE_NAME 
from EDITOR_TABLES T
where exists (select * from metafield where table_name = T.table_name
                  and field_name in (/*'DATE_CONSULTATION', */'MOTCONSU_ID'))

--select tablename from #tables

declare @table as varchar(32)
declare @sql as varchar(512)
declare @sql_t as varchar(512)
declare @sql_m as varchar(512)
declare @sql_fm as nvarchar(max)

set @sql_t='
update _table_ 
set PATIENTS_ID = _new_pat_id_
where PATIENTS_ID = _old_pat_id_
and MOTCONSU_ID=_MOTCONSU_ID_
'
set @sql_t=replace(@sql_t, '_new_pat_id_', @new_pat_id)
set @sql_t=replace(@sql_t, '_old_pat_id_', @old_pat_id)

set @sql_fm='
--услуги в направлениях
UPDATE DIR_SERV
SET
DIR_SERV.PATIENTS_ID = @new_pat_id
FROM DIR_SERV
inner JOIN PATDIREC ON PATDIREC.PATDIREC_ID = DIR_SERV.PATDIREC_ID
WHERE
PATDIREC.MOTCONSU_ID in (@MOTCONSU_ID)
and DIR_SERV.PATIENTS_ID=@old_pat_id

--талоны
UPDATE FM_BILL
SET
FM_BILL.PATIENTS_ID = @new_pat_id
FROM FM_BILL
WHERE
FM_BILL.MOTCONSU_ID in (@MOTCONSU_ID)
and FM_BILL.PATIENTS_ID=@old_pat_id

--услуги
UPDATE FM_BILLDET
SET
FM_BILLDET.PATIENTS_ID = @new_pat_id
FROM FM_BILLDET
inner JOIN FM_BILL FM_BILL ON FM_BILL.FM_BILL_ID = FM_BILLDET.FM_BILL_ID
WHERE
FM_BILL.MOTCONSU_ID in (@MOTCONSU_ID)
and FM_BILLDET.PATIENTS_ID=@old_pat_id

--оплата
UPDATE FM_BILLDET_PAY
SET
FM_BILLDET_PAY.PATIENTS_ID = @new_pat_id
FROM FM_BILLDET_PAY FM_BILLDET_PAY
inner join FM_BILLDET on (FM_BILLDET_PAY.FM_BILLDET_ID=FM_BILLDET.FM_BILLDET_ID)
inner JOIN FM_BILL FM_BILL ON FM_BILL.FM_BILL_ID = FM_BILLDET.FM_BILL_ID
WHERE
FM_BILL.MOTCONSU_ID in (@MOTCONSU_ID)
and FM_BILLDET_PAY.PATIENTS_ID=@old_pat_id

--счета
UPDATE fm_invoice
SET
fm_invoice.PATIENTS_ID = @new_pat_id
FROM FM_BILLDET_PAY FM_BILLDET_PAY
inner join FM_BILLDET on (FM_BILLDET_PAY.FM_BILLDET_ID=FM_BILLDET.FM_BILLDET_ID)
inner JOIN FM_BILL FM_BILL ON FM_BILL.FM_BILL_ID = FM_BILLDET.FM_BILL_ID
WHERE
FM_BILL.MOTCONSU_ID in (@MOTCONSU_ID)
and fm_invoice.PATIENTS_ID=@old_pat_id
'
set nocount off


------------------------------------------
exec sp_executesql @sql_fm
		, N'@new_pat_id int, @old_pat_id int, @MOTCONSU_ID int'
		, @new_pat_id=@new_pat_id
		, @old_pat_id=@old_pat_id
		, @MOTCONSU_ID=@MOTCONSU_ID

set @sql_m=replace(@sql_t, '_MOTCONSU_ID_', @MOTCONSU_ID)
-------------------------------------------
DECLARE Cur_tables CURSOR FOR
	select tablename from #tables;

OPEN Cur_tables;
FETCH NEXT FROM Cur_tables into @table;
WHILE @@FETCH_STATUS = 0
   BEGIN
	set @sql=replace(@sql_m, '_table_', @table)
	select @sql
	exec(@sql)
      FETCH NEXT FROM Cur_tables into @table;
   END;
CLOSE Cur_tables;
DEALLOCATE Cur_tables;
--------------------------------------------



drop table #tables
