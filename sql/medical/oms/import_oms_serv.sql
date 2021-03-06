/*

*/
declare 
@FM_SERV_ID int
,@id int
,@code varchar(128)
,@label varchar(512)
,@INSURANCE_TYPE char(1)
,@FM_ORG_ID int
,@FM_SERVGRP_ID int


select
@FM_SERV_ID=null
,@id=null
,@INSURANCE_TYPE='D'	--dms :) 
,@FM_ORG_ID=3		
,@FM_SERVGRP_ID=51		--omc


DECLARE cur CURSOR FOR
select 
reesus.cod
,reesus.name
from fm_serv
full join  [medialog7].[dbo].[z_reesus42] reesus on reesus.cod=code and reesus.name=label
where 
 fm_serv.code is null
--------------

OPEN Cur;
FETCH NEXT FROM Cur into @code, @label;
WHILE @@FETCH_STATUS = 0
   BEGIN
select @code, @label
	exec up_get_id  @KeyName = 'FM_SERV', @Shift = 1, @ID = @id output
INSERT INTO [FM_SERV]
           ([FM_SERV_ID]
           ,[CODE]
           ,[LABEL]
           ,[SHORT_LABEL]
           ,[DESCRIPTION]
           ,[INSURANCE_TYPE]
           ,[FM_ORG_ID]
           ,[FM_SERVGRP_ID]
           ,[STATE]
           ,[SEX]
           ,[SERV_TYPE]
           ,[PRICE_FORCED]
           ,[NEED_COMPOSITION]
           ,[PERIODICAL]
           ,[PRICE_FOR_CHANGE]
           ,[SERV_EXT_TYPE]
           ,[PRICE_TYPE]
           ,[INVOICE_TYPE]
           ,[ONCE_FOR_DAY]
           ,[OMS_CODE]
           ,[MINZDRAV_CODE]
)
     VALUES  (
	@id
	,@code
	,@label
	,@code +' '+@label
	,@label
	,@INSURANCE_TYPE
	,@FM_ORG_ID
	,@FM_SERVGRP_ID
	,'A'	--STATE
	,'A'	--SEX
	,'S'	--SERV_TYPE
	,0		--PRICE_FORCED
	,0		--NEED_COMPOSITION
	,0		--PERIODICAL
	,0		--PRICE_FOR_CHANGE
	,'S'	--SERV_EXT_TYPE
	,'S'	--PRICE_TYPE
	,'S'	--INVOICE_TYPE
	,0		--ONCE_FOR_DAY
	,@code	--OMS_CODE
	,@code	--MINZDRAV_CODE
)
      FETCH NEXT FROM Cur into @code, @label;
   END;
CLOSE Cur;
DEALLOCATE Cur;
