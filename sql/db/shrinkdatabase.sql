declare @dbname as varchar(20);
set @dbname='NuzBuh8_1';
backup log @dbname with no_log;
dbcc shrinkdatabase (@dbname,1,truncateonly);
