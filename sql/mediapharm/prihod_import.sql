/* IMP_MED_apteka */

/* поля маппинга
CNT = null
PRICE = null1
VAT = null2
IMP_CNT = CNT
IMP_PRICE = PRICE
IMP_VAT = VAT
*/

/* доп поля
SERIES=DM_LOTS.SERIES
EXPIRE_DATE=DM_LOTS.EXPIRE_DATE
VENDOR_BARCODE=DM_LOTS.VENDOR_BARCODE
CREATOR_PRICE=DM_LOTS.CREATOR_PRICE
*/

/* SQL подготовка */

/* установка кодов товара из справочника, или из файла импорта */
update imp
set
CODE=coalesce(
	(select top 1 DM_MEDS_ID 
	from US_APTEKA_MEDS spr
	where spr.ext_code=imp.ext_code
	and EXT_ORG=isnull(CONTR_CODE,'поставщик'))
,imp.EXT_CODE,
imp.CODE
)
,PRICE=coalesce(
	convert(float,replace(replace(IMP_PRICE,' ',''),',','.'))
	,PRICE
)
,CNT=coalesce(
	convert(float,replace(replace(IMP_CNT,' ',''),',','.'))
	,CNT
)
,VAT=coalesce(
	convert(float,replace(replace(IMP_VAT,' ',''),',','.'))
	,VAT
	,10
)
,CREATOR_PRICE=coalesce(
	convert(float,replace(replace(IMP_CREATOR_PRICE,' ',''),',','.'))
	,CREATOR_PRICE
)
from IMP_MED_APTEKA imp



/* SQL обработка */
declare 
@code int
,@DM_MEDS_ID int
,@DM_LOTS_ID int
,@IMPORT_RECORD_ID int
,@cnt int
,@CONTR_CODE varchar(64)

set @IMPORT_RECORD_ID=1-- :IMPORT_RECORD_ID

/* добавление в справочник соответствий товаров, если еще нет */
select 
@code =ext_code
,@DM_MEDS_ID=_DM_MEDS_ID 
,@CONTR_CODE=isnull(CONTR_CODE,'поставщик')
from IMP_MED_APTEKA imp
where 
_STATUS = 100
and IMP_MED_apteka_ID =@IMPORT_RECORD_ID
and _DM_MEDS_ID is not null

if(@code is not null and @DM_MEDS_ID is not null)
begin
	select @cnt=count(*) 
	from US_APTEKA_MEDS 
	where 
	DM_MEDS_ID=@DM_MEDS_ID
	 and ext_code =@code
	 and EXT_ORG=@CONTR_CODE

	if(@cnt=0)
	begin
	
	declare @P1 int
	exec up_get_id  @KeyName = 'US_APTEKA_MEDS', @Shift = 1, @ID = @P1 output
	insert into US_APTEKA_MEDS (US_APTEKA_MEDS_ID,EXT_ORG,EXT_CODE,DM_MEDS_ID)
	values
	(@P1
	,@CONTR_CODE
	,@code
	,@DM_MEDS_ID
	)
	
	end 
end

/* номер новой партии */
select 
@DM_LOTS_ID=DM_TRANSFERS.DM_LOTS_ID
from IMP_MED_APTEKA imp
join DM_TRANSFERS on imp._DM_TRANSFERS_ID=DM_TRANSFERS.DM_TRANSFERS_ID
where 
_STATUS = 100
and IMP_MED_apteka_ID = @IMPORT_RECORD_ID
and _DM_MEDS_ID is not null

/* поиск наценки из предыдущей партии */
declare @MARKUP int

select top 1 
@MARKUP=MARKUP 
from DM_LOTS L 
where L.DM_MEDS_ID=@DM_MEDS_ID
and L.DM_LOTS_ID<>@DM_LOTS_ID
order by L.DM_LOTS_ID desc

/* установка реквизитов новой партии */
update DM_LOTS set 
MARKUP=isnull(@MARKUP,0)
,SERIES=imp.SERIES
,EXPIRE_DATE=imp.EXPIRE_DATE
,VENDOR_BARCODE=imp.VENDOR_BARCODE
,CREATOR_PRICE=imp.CREATOR_PRICE
from DM_LOTS L 
join DM_TRANSFERS T on t.DM_LOTS_ID=L.DM_LOTS_ID 
join IMP_MED_APTEKA imp on imp._DM_TRANSFERS_ID=T.DM_TRANSFERS_ID
where L.DM_LOTS_ID=@DM_LOTS_ID
and L.DM_MEDS_ID=@DM_MEDS_ID
and imp.IMP_MED_apteka_ID = @IMPORT_RECORD_ID

