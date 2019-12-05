
CREATE PROCEDURE [dbo].[EK_DM_COSTS_recalc] 
as begin
/*
Обновление стоимости всех затрат, у которых есть текущие остатки на складах
*/
set nocount on

declare
	@CostId INT
	,@DeviseId int
	,@CoursTypeId int
	,@res MONEY 
	,@old_price money
	,@cnt float

select 
	@DeviseId=2		/* рубль */
	,@CoursTypeId=2	/* внутренний курс */

DECLARE cur CURSOR FOR 
-------------------
SELECT
	C.DM_COSTS_ID
	,c.PRICE 
FROM DM_COSTS C, DM_COST_GROUPS G 
WHERE  C.DM_COST_GROUPS_ID = G.DM_COST_GROUPS_ID AND
        G.COST_GROUP_TYPE = 'M' AND 
        C.PRICE_TYPE = 'M' 
order by C.DM_COSTS_ID
-------------------
select '@CostId', '@old_price', '@res', '@cnt'

OPEN cur 
FETCH NEXT FROM cur INTO @CostId, @old_price 
WHILE @@FETCH_STATUS = 0 
BEGIN 
------------
	/* поиск остатков */
	select @res=0
	SELECT @cnt=SUM(W.QUANTITY)
	FROM 
    DM_WAREHOUSE W
    join DM_LOTS L on L.DM_LOTS_ID = W.DM_LOTS_ID 
    join DM_MEDS M on M.DM_MEDS_ID = L.DM_MEDS_ID 
	WHERE
    M.DM_COSTS_ID = @CostId

	/* если есть остатки, пересчитываем затраты */
	if (@cnt>0) 
		EXEC GetMiddleCostPrice @CostId, @DeviseId, @CoursTypeId, @Res OUTPUT 

	select @CostId, @old_price, @res, @cnt
	/* если цена изменилась, обновляем */
	IF (@res>0 and @Res <> @old_price) 
		UPDATE DM_COSTS SET PRICE = @res WHERE DM_COSTS_ID = @CostId 
	FETCH NEXT FROM cur INTO @CostId, @old_price 
------------
END   
DEALLOCATE cur 


end -- procedure


/*
штатная функция
CREATE PROCEDURE [dbo].[GetMiddleCostPrice](@CostId int, @DeviseId int, @CoursTypeId int, @res money OUTPUT)
AS
BEGIN
  SELECT @Res = (SUM(W.QUANTITY*L.DEV_PRICE)/SUM(W.QUANTITY * IsNull(M.COST_PACK, 1)))
  FROM 
    DM_WAREHOUSE W, 
    DM_LOTS L, 
    DM_MEDS M 
  WHERE 
    L.DM_LOTS_ID = W.DM_LOTS_ID 
    AND M.DM_MEDS_ID = L.DM_MEDS_ID 
    AND M.DM_COSTS_ID = @CostId 
  IF (ISNULL(@Res, 0) = 0)      
      SELECT @Res = PRICE FROM DM_COSTS WHERE DM_COSTS_ID = @CostId 
END
*/
