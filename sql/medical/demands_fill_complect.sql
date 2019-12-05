DECLARE @DM_DEMANDS_ID as INT
	,@MEDECINS_ID as INT
	,@CURRENT_USER as int
	,@STATUS as int
	,@WAREHOUSE_ID as int
	,@DM_MEDS_ID as int
	,@DM_MEASURE_ID as int
	,@CNT as numeric(20,10)
	,@NEW_ID as int
	
declare @ERRNO   int, @ERRMSG  varchar(255)

set nocount on

select @MEDECINS_ID=null 
	,@CURRENT_USER=787 -- :%AF_CURRENT_MEDECIN
	,@DM_DEMANDS_ID=1808 -- :DM_DEMANDS.DM_DEMANDS_ID

/*
SOURCE_WH_ID --если внутреннее требование, склад-заказчик, иначе null
DEST_WH_ID --если внутреннее требование, склад-поставщик, иначе склад заказчик.
*/

select 
	@MEDECINS_ID=DM_DEMANDS.MEDECINS_CR_ID
	,@STATUS=ACCEPTED
	,@WAREHOUSE_ID=coalesce(SOURCE_WH_ID,DEST_WH_ID)
from DM_DEMANDS
where DM_DEMANDS_ID=@DM_DEMANDS_ID

if(@DM_DEMANDS_ID is null)
	select @ERRNO = 50001, @ERRMSG  =' Ќе выбран документ.'

/* проверка прав текущего пользовател€ к пользователю создавшему документ */
else if(isnull(dbo.ek_motconsu_check_user_ACL (null, @MEDECINS_ID, @CURRENT_USER),0)=0)
	select @ERRNO = 50001, @ERRMSG  ='Ќет прав на редактирование документа.'

else if(@STATUS=1)
	select @ERRNO = 50001, @ERRMSG  ='ƒокумент уже прин€т.'

else if (exists(select DM_DEM_GOODS_ID from DM_DEM_GOODS where DM_DEMANDS_ID=@DM_DEMANDS_ID))
     select @ERRNO = 50001, @ERRMSG  ='ƒокумент уже заполнен.'
     
else if(isnull(@WAREHOUSE_ID,0)=0)
	select @ERRNO = 50001, @ERRMSG  ='Ќе заполнен склад-заказчик.'     

if(@ERRNO>0)
     raiserror @ERRNO @ERRMSG 
else
begin

DECLARE cur CURSOR 
   LOCAL           -- LOCAL or GLOBAL
   FORWARD_ONLY    -- FORWARD_ONLY or SCROLL
   STATIC          -- STATIC, KEYSET, DYNAMIC, or FAST_FORWARD
   READ_ONLY       -- READ_ONLY, SCROLL_LOCKS, or OPTIMISTIC
   TYPE_WARNING    -- Inform me of implicit conversions
FOR
-----------------------
with OST as(
select L.DM_MEDS_ID, SUM(W.QUANTITY) as Q
from DM_WAREHOUSE W WITH(NOLOCK)
join DM_LOTS L on L.DM_LOTS_ID=w.DM_LOTS_ID
where 
w.DM_WAREHOUSES_ID=@WAREHOUSE_ID
--join DM_MEDS M on M.DM_MEDS_ID=L.DM_MEDS_ID
group by L.DM_MEDS_ID
)
select 
b.DM_MEDS_ID
,DM_MEDS.DM_MEASURE_ID
--,b.COMPLECT
--,isnull(ost.Q,0) as q
,b.COMPLECT-isnull(ost.Q,0) as delta
from DM_MED_BACKLOG B
join DM_MEDS on DM_MEDS.DM_MEDS_ID=b.DM_MEDS_ID
left join OST on OST.DM_MEDS_ID=B.DM_MEDS_ID
where 
B.DM_WAREHOUSES_ID=@WAREHOUSE_ID
and isnull(DM_MEDS.ARCHIVE,0)=0
and b.COMPLECT>ISNULL(ost.Q,0)
order by delta desc
-------------------------
OPEN Cur;
FETCH NEXT FROM Cur into @DM_MEDS_ID, @DM_MEASURE_ID, @CNT;
WHILE @@FETCH_STATUS = 0
	BEGIN
	---------------------------------
		select @DM_MEDS_ID, @DM_MEASURE_ID, @CNT
/*	
		exec up_get_id  @KeyName = 'DM_DEM_GOODS', @Shift = 1, @ID = @NEW_ID output

		insert into DM_DEM_GOODS
		(DM_DEM_GOODS_ID,DM_DEMANDS_ID
		,DM_MEDS_ID
		,QUANTITY
		,DM_MEASURE_ID,MEASURE_FACTOR
		,PRICE,DEM_GOOD_USER_STATE
		,DEM_GOOD_STATE
		)
		values
		(@NEW_ID,@DM_DEMANDS_ID
		,@DM_MEDS_ID
		,@CNT
		,@DM_MEASURE_ID,1
		,0,0
		,'N')
*/
	---------------------------------
		FETCH NEXT FROM Cur into @DM_MEDS_ID, @DM_MEASURE_ID, @CNT;
	END;
CLOSE Cur;
DEALLOCATE Cur;


end


