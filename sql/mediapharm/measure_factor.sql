INSERT DM_TRANSFERS ( DM_TRANSFERS_ID, DM_DOC_ID
, DM_LOTS_ID
, QUANTITY, LACK, SPOILAGE, PRICE, DM_MEASURE_ID, MEASURE_FACTOR, TRANSFERS_SUM, TRANSFERS_NDS, FM_DEVISE_ID, SUM_BY_HAND, NDS_BY_HAND) 
VALUES ( 122315, 15490
, 5618
, 0, 0, 0, 2.225
, 126, 1, 0, 0, 2, 0, 0)


declare 
 @DM_LOTS_ID	int
,@DM_MEASURE_ID int

select
@DM_LOTS_ID=5618
,@DM_MEASURE_ID=126

select dbo.dmGetMeasureFactor(@DM_LOTS_ID, @DM_MEASURE_ID)



select FM_BILL_id from FM_BILLDET where FM_BILLDET_ID=70043

select
*
from DM_MEDS where DM_MEDS_ID=4647