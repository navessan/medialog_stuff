IF EXISTS(SELECT  DM_LOTS.DM_LOTS_ID FROM  DM_LOTS 
				WHERE (cast(DM_LOTS.KRN_CREATE_DATE as date)=cast(getdate() as date)))
begin

declare @date datetime
	,@tableHTML  NVARCHAR(MAX)
	,@emails NVARCHAR(MAX)
	
set @emails='n@mru'

SET @tableHTML =
    N'<H1></H1>' +
    N'<table bordercolor="green" border="2">' +
    N'<tr bgcolor="#F7FF47"><th>№</th><th>Дата</th><th>Код</th><th>Наименование</th>
    <th>Техкарта</th><th>Срок годности</th><th>Ед.измерения</th><th>Стоимость,руб</th>
    <th>Макс/Сред/Мин стоимость, руб</th><th>Цена реализации, руб</th>
    <th>Наценка</th><th>Макс/Сред/Мин цена реализации, руб</th>
    <th>Текущий остаток</th><th>Мин. остаток</th><th>Наименование поставщика</th></tr>'

select @date=CAST(Getdate() AS Date)
--select @date

select @tableHTML =@tableHTML +CAST(
(---------------
select
td=t.[N]
,'' ,td=t.[Дата]
,'' ,td=t.[Код]
,'' ,td=t.[Наименование]
,'' ,td=t.[Техкарта]
,'' ,td=t.[Срок годности]
,'' ,td=t.[Ед.измерения]
,'' ,td=t.[Стоимость,руб]
,'' ,td=t.[Макс/Сред/Мин стоимость, руб]
,'' ,td=t.[Цена реализации, руб]
,'' ,td=t.[Наценка]
,'' ,td=t.[Макс/Сред/Мин цена реализации, руб]
,'' ,td=t.[Текущий остаток]
,'' ,td=t.[Мин. остаток]
,'' ,td=t.[Наименование поставщика]
,''
from (
-----------------
SELECT 
row_number() OVER( Order by DM_MEDS.LABEL)
	as [N],
CAST(CAST(DM_LOTS_1.KRN_CREATE_DATE as date) as varchar(10))+' '+CAST(CAST(DM_LOTS_1.KRN_CREATE_DATE as time) as varchar(8))
	as [Дата],
ISNULL(DM_MEDS.CODE,'-')
	as [Код],
ISNULL(DM_MEDS.LABEL,'-')
	as [Наименование],
CASE
	when DM_MEDS.DM_COSTS_ID is null then '-'
	else 'ДА' end
	as [Техкарта],
ISNULL(CAST(CAST(expire_date as date) as varchar(10)),'-')
	as [Срок годности],
ISNULL(DM_MEASURE.LABEL ,'-')
	as [Ед.измерения],
CAST(CAST(ROUND(DM_LOTS_1.PRICE,2) as float(8)) as varchar(max))
	as [Стоимость,руб],
COALESCE((select  CAST(CAST(ROUND(MAX(DM_LOTS_2.PRICE),2) as float (8)) as varchar(max))
				+' / '+
				CAST(CAST(ROUND(AVG(DM_LOTS_2.PRICE),2) as float (8)) as varchar(max))
				+' / '+
				CAST(CAST(ROUND(MIN(DM_LOTS_2.PRICE),2) as float (8)) as varchar(max)) 
			from DM_LOTS DM_LOTS_2 
			where DM_LOTS_2.KRN_CREATE_DATE > CAST(@date-90 AS Date) and 
				  DM_LOTS_2.KRN_CREATE_DATE < CAST(@date AS Date)	and 
				  DM_LOTS_2.DM_MEDS_ID=DM_LOTS_1.DM_MEDS_ID
			group by DM_MEDS_ID)
		,(select  CAST(CAST(ROUND(MAX(DM_LOTS_2.PRICE),2) as float (8)) as varchar(max))
				  +' / '+
				  CAST(CAST(ROUND(AVG(DM_LOTS_2.PRICE),2) as float (8)) as varchar(max))
				  +' / '+
				  CAST(CAST(ROUND(MIN(DM_LOTS_2.PRICE),2) as float (8)) as varchar(max))+'*' 
			from DM_LOTS DM_LOTS_2 
			where (DM_LOTS_2.KRN_CREATE_DATE >cast(CAST(@date-180 AS Date) as datetime) and 
				   DM_LOTS_2.KRN_CREATE_DATE < cast(CAST(@date AS Date) as datetime) and 
				   DM_LOTS_2.DM_MEDS_ID=DM_LOTS_1.DM_MEDS_ID)
			group by DM_MEDS_ID)
		,'-')
	as [Макс/Сред/Мин стоимость, руб],					
CAST(CAST(ROUND(DM_LOTS_1.SALE_SUM,2) as float(8)) as varchar(max))
	as [Цена реализации, руб],
CAST(CAST(ROUND(DM_LOTS_1.MARKUP,2) as float(8)) as varchar(max))
	as [Наценка],					
COALESCE((select CAST(CAST(ROUND(MAX(DM_LOTS_2.SALE_SUM),2) as float (8)) as varchar(max))
				+' / '+
				CAST(CAST(ROUND(AVG(DM_LOTS_2.SALE_SUM),2) as float (8)) as varchar(max))
				+' / '+
				CAST(CAST(ROUND(MIN(DM_LOTS_2.SALE_SUM),2) as float (8)) as varchar(max)) 
			from DM_LOTS DM_LOTS_2 
			where DM_LOTS_2.KRN_CREATE_DATE >cast(CAST(@date-90 AS Date) as datetime) and 
				  DM_LOTS_2.KRN_CREATE_DATE <cast(CAST(@date AS Date) as datetime) and 
			      DM_LOTS_2.DM_MEDS_ID=DM_LOTS_1.DM_MEDS_ID
			group by DM_MEDS_ID)
		,(select CAST(CAST(ROUND(MAX(DM_LOTS_2.SALE_SUM),2) as float (8)) as varchar(max))
				+' / '+
				 CAST(CAST(ROUND(AVG(DM_LOTS_2.SALE_SUM),2) as float (8)) as varchar(max))
				+' / '+
				 CAST(CAST(ROUND(MIN(DM_LOTS_2.SALE_SUM),2) as float (8)) as varchar(max))+'*' 
			from DM_LOTS DM_LOTS_2 
			where DM_LOTS_2.KRN_CREATE_DATE > cast(CAST(@date-180 AS Date) as datetime) and 
				  DM_LOTS_2.KRN_CREATE_DATE < cast(CAST(@date AS Date) as datetime) and 
				  DM_LOTS_2.DM_MEDS_ID=DM_LOTS_1.DM_MEDS_ID
			group by DM_MEDS_ID)
		,'-')
	as [Макс/Сред/Мин цена реализации, руб],			
ISNULL((CAST(CAST(ROUND((SELECT SUM(DM_WAREHOUSE.QUANTITY)
			FROM DM_WAREHOUSE DM_WAREHOUSE
			JOIN DM_LOTS DM_LOTS_5 ON DM_LOTS_5.DM_LOTS_ID = DM_WAREHOUSE.DM_LOTS_ID 
			JOIN DM_MEDS DM_MEDS_5 ON DM_MEDS_5.DM_MEDS_ID = DM_LOTS_5.DM_MEDS_ID 
			where dm_meds_5.code=DM_MEDS.CODE),2) 
		as float(10))as varchar(10)))
		,'-')
	as [Текущий остаток],	   
ISNULL(CAST(CAST((select top 1 dm_med_backlog.quantity 
			from dm_med_backlog 
			where dm_med_backlog.dm_meds_id=DM_MEDS.DM_MEDS_ID and 
				dm_med_backlog.dm_warehouses_id=1) 
			as float(8)) as varchar(max))
			,'-')
	as [Мин. остаток],
ISNULL((SELECT FM_ORG.LABEL
		FROM DM_LOTS DM_LOTS_7
		join DM_TRANSFERS on DM_LOTS_7.DM_LOTS_ID=DM_TRANSFERS.DM_LOTS_ID 
		join DM_DOC on DM_TRANSFERS.DM_DOC_ID=DM_DOC.DM_DOC_ID
		join FM_ORG on DM_DOC.FM_ORG_ID=FM_ORG.FM_ORG_ID
		Where 
		DM_LOTS_7.KRN_CREATE_DATE <= @date and
		DM_LOTS_7.DM_LOTS_ID=DM_LOTS_1.DM_LOTS_ID)	
	,'-')
	as [Наименование поставщика]
FROM DM_LOTS DM_LOTS_1
left outer join DM_MEDS on dm_meds.DM_MEDS_ID=DM_LOTS_1.DM_MEDS_ID
left outer JOIN DM_MEASURE DM_MEASURE ON DM_MEASURE.DM_MEASURE_ID = DM_MEDS.DM_MEASURE_ID          
WHERE 
cast(DM_LOTS_1.KRN_CREATE_DATE as DATE) = @date
--ORDER BY DM_MEDS.LABEL
------------------------
) as t
order by t.Наименование
for XML PATH('tr'), TYPE
)
as nvarchar(max))

select @tableHTML=@tableHTML+
    N'</table>' +
    N'<HR>'+
    N'<b>С уважением.</b>';

select @tableHTML

    
EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'm',
	@recipients=@emails,
    @subject = 'Отчет по партиям',
    @body = @tableHTML,
    @body_format = 'HTML' ;    
    
end
