/*
SELECT top 10
tmu.*
,fm_serv_id
,fm_serv.code
,fm_serv.label
,fm_serv.state
,(select top 1 price 
	from fm_servprice 
	where fm_servprice.fm_serv_id=fm_serv.fm_serv_id
	order by date_from desc)/tmu.tarif price
 
 FROM z_tarimu65 tmu
inner join fm_serv on 'о'+convert(varchar(32),tmu.cod)=fm_serv.code
*/
declare 
@DATE_FROM datetime
,@FM_DEVISE_ID int			--Валюта  
,@FM_PRICE_CATEGORY_ID int	--Категория цен  
,@FM_PRICETYPE_ID int		--Тип цены  
,@FM_SERV_ID int
,@price float
,@id int

select
@DATE_FROM='2013-11-01'
,@FM_DEVISE_ID=2			--rub
,@FM_PRICE_CATEGORY_ID=1	--base
,@FM_PRICETYPE_ID=6			--oms
,@FM_SERV_ID=null
,@price=null
,@id=null

DECLARE cur CURSOR FOR
SELECT
tmu.tarif
,fm_serv.fm_serv_id
 FROM medialog7.dbo.tarif1113 tmu
inner join fm_serv on 'о'+convert(varchar(32),tmu.cod)=fm_serv.code
left join fm_servprice on fm_serv.fm_serv_id=fm_servprice.fm_serv_id and fm_servprice.date_from=@DATE_FROM and FM_PRICETYPE_ID=@FM_PRICETYPE_ID

where code like 'о%'
and state ='a'
and fm_servprice.fm_servprice_id is null
--------------

OPEN Cur;
FETCH NEXT FROM Cur into @price, @FM_SERV_ID;
WHILE @@FETCH_STATUS = 0
   BEGIN
	exec up_get_id  @KeyName = 'FM_SERVPRICE', @Shift = 1, @ID = @id output
	INSERT INTO [FM_SERVPRICE]       
		([FM_SERVPRICE_ID]
           ,[FM_SERV_ID]
           ,[FM_PRICETYPE_ID]
           ,[PRICE]
           ,[FM_DEVISE_ID]
           ,[DATE_FROM]
           ,[FM_PRICE_CATEGORY_ID])
     VALUES
           (@id
           ,@FM_SERV_ID
           ,@FM_PRICETYPE_ID
           ,@PRICE
           ,@FM_DEVISE_ID
           ,@DATE_FROM
           ,@FM_PRICE_CATEGORY_ID)
      FETCH NEXT FROM Cur into @price, @FM_SERV_ID;
   END;
CLOSE Cur;
DEALLOCATE Cur;
