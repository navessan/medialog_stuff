ALTER procedure [dbo].[US_skud_report_month]
as
begin

set nocount on;
/*
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'xp_cmdshell', 1;
GO
RECONFIGURE;
GO
set language english
go
*/

declare
	@D DateTime 
	,@DateFrom DateTime
	,@DateTo DateTime
	,@LastMonth int

select 
	@D=GETDATE()
	,@LastMonth=1		--нужный месяц из прошедших

/*
SELECT DATEADD(month, DATEDIFF(month, 0, @D), 0) AS StartOfMonth
		,DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, @D) + 1, 0))	as EndOfMonth
*/

SELECT @DateFrom=DATEADD(month, DATEDIFF(month, 0, @D)-@LastMonth, 0)
	,@DateTo=DATEADD(d, -1, DATEADD(m, DATEDIFF(MONTH, 0, @D)+1-@LastMonth, 0))

/*
SELECT @DateFrom={ts'2016-10-28 00:00:00.000'}
	,@DateTo={ts'2016-10-31 00:00:00.000'}
*/

declare @date datetime
	,@tableHTML  NVARCHAR(MAX)
	,@emails NVARCHAR(MAX)
	
set @emails='nov@m.ru'
--;d@m.ru'

/*
копирование файла из шаблона
*/

declare @Folder varchar(255)
		,@DocumentBlank varchar(255)
		,@DocumentLong varchar(255)
		
select @Folder = 'c:\data\test\'
		,@DocumentBlank = 'blank_m_month_skud_report'
		,@DocumentLong = 'm_month_skud_report'
 
DECLARE @CMD NVARCHAR(4000)
SET @CMD = 'COPY "' + @folder + @DocumentBlank + '.xls" "' + @Folder + @DocumentLong + '.xls"'
exec master..xp_cmdshell @CMD
----------------------------

IF OBJECT_ID(N'z_skud') is not null
DROP TABLE [dbo].[z_skud]
create table z_skud(d datetime,dep varchar(512),name varchar(512),start_time datetime,start_place varchar(512),end_time datetime,end_place varchar(512),work datetime)

exec [dbo].[us_sp_skud_table] @DateFrom, @DateTo

---------------------------
/* экспорт в файл */
-------------
INSERT INTO
--select * from
 OPENROWSET (
	'Microsoft.ACE.OLEDB.12.0'
	,'Excel 12.0; HDR=NO; Database=c:\data\test\m_month_skud_report.xls'
	,'select * from [Лист1$]'
	)
-------------
select 
dep,name
,round(sum(
datediff(hh, 0, work ) 
+
cast(DATEPART(MINUTE,work) as float)/60
),2) as hour_sum
,max(case when datepart(DAY,d)=1 then convert(varchar(20),work,108) else '' end) as [1]
,max(case when datepart(DAY,d)=2 then convert(varchar(20),work,108) else '' end) as [2]
,max(case when datepart(DAY,d)=3 then convert(varchar(20),work,108) else '' end) as [3]
,max(case when datepart(DAY,d)=4 then convert(varchar(20),work,108) else '' end) as [4]
,max(case when datepart(DAY,d)=5 then convert(varchar(20),work,108) else '' end) as [5]
,max(case when datepart(DAY,d)=6 then convert(varchar(20),work,108) else '' end) as [6]
,max(case when datepart(DAY,d)=7 then convert(varchar(20),work,108) else '' end) as [7]
,max(case when datepart(DAY,d)=8 then convert(varchar(20),work,108) else '' end) as [8]
,max(case when datepart(DAY,d)=9 then convert(varchar(20),work,108) else '' end) as [9]
,max(case when datepart(DAY,d)=10 then convert(varchar(20),work,108) else '' end) as [10]
,max(case when datepart(DAY,d)=11 then convert(varchar(20),work,108) else '' end) as [11]
,max(case when datepart(DAY,d)=12 then convert(varchar(20),work,108) else '' end) as [12]
,max(case when datepart(DAY,d)=13 then convert(varchar(20),work,108) else '' end) as [13]
,max(case when datepart(DAY,d)=14 then convert(varchar(20),work,108) else '' end) as [14]
,max(case when datepart(DAY,d)=15 then convert(varchar(20),work,108) else '' end) as [15]
,max(case when datepart(DAY,d)=16 then convert(varchar(20),work,108) else '' end) as [16]
,max(case when datepart(DAY,d)=17 then convert(varchar(20),work,108) else '' end) as [17]
,max(case when datepart(DAY,d)=18 then convert(varchar(20),work,108) else '' end) as [18]
,max(case when datepart(DAY,d)=19 then convert(varchar(20),work,108) else '' end) as [19]
,max(case when datepart(DAY,d)=20 then convert(varchar(20),work,108) else '' end) as [20]
,max(case when datepart(DAY,d)=21 then convert(varchar(20),work,108) else '' end) as [21]
,max(case when datepart(DAY,d)=22 then convert(varchar(20),work,108) else '' end) as [22]
,max(case when datepart(DAY,d)=23 then convert(varchar(20),work,108) else '' end) as [23]
,max(case when datepart(DAY,d)=24 then convert(varchar(20),work,108) else '' end) as [24]
,max(case when datepart(DAY,d)=25 then convert(varchar(20),work,108) else '' end) as [25]
,max(case when datepart(DAY,d)=26 then convert(varchar(20),work,108) else '' end) as [26]
,max(case when datepart(DAY,d)=27 then convert(varchar(20),work,108) else '' end) as [27]
,max(case when datepart(DAY,d)=28 then convert(varchar(20),work,108) else '' end) as [28]
,max(case when datepart(DAY,d)=29 then convert(varchar(20),work,108) else '' end) as [29]
,max(case when datepart(DAY,d)=30 then convert(varchar(20),work,108) else '' end) as [30]
,max(case when datepart(DAY,d)=31 then convert(varchar(20),work,108) else '' end) as [31]
from z_skud as tbl
group by dep,name
order by dep,name

----------------------
/*
отправка почты
*/

	DECLARE @Body VARCHAR(2000)
		,@Attachments varchar(255)
		,@subj varchar(100)
		
	select @Attachments = @Folder + @DocumentLong  + '.xls'
			,@tableHTML = 'Отчет по СКУД за ' + CONVERT(VARCHAR(10), @DateFrom, 102)+' - '+ CONVERT(VARCHAR(10), @DateTo, 102)
			,@subj= 'Отчет по СКУД '+DATENAME(mm, @DateFrom)
   
    EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'm',
	@recipients=@emails,
    @subject = @subj,
    @body = @tableHTML,
    @body_format = 'HTML',
    @file_attachments = @Attachments;
        
end
