/*
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
@DATE_FROM='2014-01-01'
,@FM_DEVISE_ID=2			--rub
,@FM_PRICE_CATEGORY_ID=1	--base
,@FM_PRICETYPE_ID=6			--oms
,@FM_SERV_ID=null
,@price=null
,@id=null

DECLARE cur CURSOR FOR
SELECT
tmu.tarif
,fm_serv_id
 FROM medialog7.dbo.z_tarimu74 tmu
inner join fm_serv on 'о'+convert(varchar(32),tmu.cod)=fm_serv.code

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