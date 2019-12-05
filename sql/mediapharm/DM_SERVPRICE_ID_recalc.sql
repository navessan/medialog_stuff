
CREATE PROCEDURE [dbo].[EK_DM_SERVPRICE_recalc] 
as begin
/*
Создание новых составов затрат для услуг, у которых изменилась стоимость по сумме затрат
*/

set nocount on

declare	@DM_COSTS_ID int
		,@FM_SERV_ID int
		,@DM_SERVPRICE_ID int
		,@new_DM_SERVPRICE_ID int
		,@old_SERV_MED int
		,@new_SERV_MED int
		,@PriceCategoryId int
		,@old_price money
		,@new_price money
		,@res1 money 

select @PriceCategoryId =1


DECLARE cur CURSOR FOR 
-------------------
/* услуги с затратами */
SELECT distinct
 DM_SERVPRICE.FM_SERV_ID
FROM
 DM_SERVPRICE DM_SERVPRICE
 join FM_SERV on FM_SERV.FM_SERV_ID=DM_SERVPRICE.FM_SERV_ID
 join DM_SERV_MEDS M on M.DM_SERVPRICE_ID=DM_SERVPRICE.DM_SERVPRICE_ID
 join DM_COSTS C on M.DM_COSTS_ID = C.DM_COSTS_ID
WHERE
 IS_FACT = 'N'
 and FM_SERV.STATE not in ('H')
 --and FM_SERV.fm_serv_id >10744
 order by DM_SERVPRICE.FM_SERV_ID
-------------------

OPEN cur 
FETCH NEXT FROM cur INTO @FM_SERV_ID 
WHILE @@FETCH_STATUS = 0 
BEGIN 
------------	
	/* поиск последней себестоимости */
	select top 1 @DM_SERVPRICE_ID=DM_SERVPRICE.DM_SERVPRICE_ID
	FROM DM_SERVPRICE DM_SERVPRICE 
	WHERE
	 IS_FACT = 'N' AND DM_SERVPRICE.FM_SERV_ID=@FM_SERV_ID
	order by CREATION_DATE desc

	/* текущая цена */
	SELECT 
	 @old_price=DM_SERVPRICE.PRIME_COST
	,@new_price=sum(Round(
		case when c.PRICE_TYPE='P' then DM_SERVPRICE.PRICE / 100 * c.PRICE else c.PRICE end
			,2)* m.QUANTITY
		)
	FROM
	 DM_SERVPRICE DM_SERVPRICE 
	 join DM_SERV_MEDS M on M.DM_SERVPRICE_ID=DM_SERVPRICE.DM_SERVPRICE_ID
	 join DM_COSTS C on M.DM_COSTS_ID = C.DM_COSTS_ID
	WHERE
	 IS_FACT = 'N' AND DM_SERVPRICE.DM_SERVPRICE_ID = @DM_SERVPRICE_ID
	 and IS_ACTIVE = 1 and isnull(IS_DELETED,0)=0
	group by
	DM_SERVPRICE.PRIME_COST

	/* округляем еще раз, тк сумма округлений может дать три знака после запятой 276,535 -> 276,54 */
	select @new_price=round(@new_price,2)

	if(@new_price>0 and @old_price<>@new_price)
	begin
		/* цена изменилась */
		select @FM_SERV_ID, 'new price:', @new_price, 'old price:', @old_price
		
		/* создаем новый состав */
		exec up_get_id  @KeyName = 'DM_SERVPRICE', @Shift = 1, @ID = @new_DM_SERVPRICE_ID output
		
		insert into DM_SERVPRICE
		(DM_SERVPRICE_ID
		,FM_SERV_ID
		,CREATION_DATE
		,PRICE,PRIME_COST
		,IS_FACT
		,DM_SERVPRICE_NORM_ID
		)
		values(
		@new_DM_SERVPRICE_ID
		,@FM_SERV_ID
		,dateadd(d,datediff(d,0,getdate()),0)
		,@old_price,@old_price
		,'N'
		,@new_DM_SERVPRICE_ID
		)
		
		/* заполняем новый состав */
		DECLARE cur_med CURSOR FOR 
			select DM_SERV_MEDS_ID
			from DM_SERV_MEDS 
			where DM_SERVPRICE_ID=@DM_SERVPRICE_ID
		-------------------
		OPEN cur_med 
		FETCH NEXT FROM cur_med INTO @old_SERV_MED
		WHILE @@FETCH_STATUS = 0 
		BEGIN 
		------------
			exec up_get_id  @KeyName = 'DM_SERV_MEDS', @Shift = 1, @ID = @new_SERV_MED output

			INSERT DM_SERV_MEDS (DM_SERV_MEDS_ID
			, DM_SERVPRICE_ID
			, PRICE, QUANTITY, PRICE_TYPE
			, DM_COSTS_ID, NOTE, IS_DELETED, IS_ACTIVE, COST_GROUP
			, DM_SERV_MEDS_NORM_ID, COST_SUM, PERSONALIZED)
			select 
			@new_SERV_MED			as DM_SERV_MEDS_ID
			, @new_DM_SERVPRICE_ID	as DM_SERVPRICE_ID
			, PRICE, QUANTITY, PRICE_TYPE
			, DM_COSTS_ID, NOTE, IS_DELETED, IS_ACTIVE, COST_GROUP
			, @new_SERV_MED			as DM_SERV_MEDS_NORM_ID
			, COST_SUM, PERSONALIZED
			from DM_SERV_MEDS 
			where DM_SERV_MEDS_ID=@old_SERV_MED

			FETCH NEXT FROM cur_med INTO @old_SERV_MED
		------------
		END   
		DEALLOCATE cur_med		

		/* пересчет себестоимости */
		exec RecalcComposition @new_DM_SERVPRICE_ID, @PriceCategoryId
		
	end
	else
		/* цена не изменилась */
		select @FM_SERV_ID, 'price:', @new_price, 'price:', @old_price

	FETCH NEXT FROM cur INTO @FM_SERV_ID
------------
END   
DEALLOCATE cur 


end
/*
------------
	SELECT 
	 DM_SERVPRICE.DM_SERVPRICE_ID, DM_SERVPRICE.FM_SERV_ID
	,DM_SERVPRICE.CREATION_DATE
	,DM_SERVPRICE.PRICE
	,DM_SERVPRICE.PRIME_COST, DM_SERVPRICE.IS_FACT
	,sum(m.COST_SUM) as old_sum
	,sum(Round(
		case when c.PRICE_TYPE='P' then DM_SERVPRICE.PRICE / 100 * c.PRICE else c.PRICE end
			,2)* m.QUANTITY
		) as new_sum
FROM
 DM_SERVPRICE DM_SERVPRICE 
 left join DM_SERV_MEDS M on M.DM_SERVPRICE_ID=DM_SERVPRICE.DM_SERVPRICE_ID
 left join DM_COSTS C on M.DM_COSTS_ID = C.DM_COSTS_ID
WHERE
 IS_FACT = 'N' AND DM_SERVPRICE.DM_SERVPRICE_ID = @DM_SERVPRICE_ID
 and IS_ACTIVE = 1
 and isnull(IS_DELETED,0)=0
group by
 DM_SERVPRICE.DM_SERVPRICE_ID, DM_SERVPRICE.FM_SERV_ID
,DM_SERVPRICE.CREATION_DATE
,DM_SERVPRICE.PRICE, DM_SERVPRICE.MEDECINS_ID, 
DM_SERVPRICE.PRIME_COST, DM_SERVPRICE.IS_FACT
*/