declare @import_id int
set @import_id=1

set nocount on

declare @data varchar(4000)
	,@data_len int
	,@pos int
	,@val_name varchar(32)
	,@mes varchar(32)
	,@l int
	,@float_pos int
	,@descr varchar(32)
	
	,@v_str varchar(32)


select 
@data=rawdata
from [us_lab_import]
where us_lab_import_id=@import_id


/*
Text distinction code I	 1 "D"
Text distinction code ll 1 "1"
Sample distinction code	 1 "U"
Year (Month or Day)		 2 "97"
Month (or Day)			 2 "09"
Day (or Year)			 2 "30"
Analysis information	 1 (O)
Sample ID No.			 12 (OOOOOOOOOOOO)
PDA information			 6 (OOOOOO)
RDW select information	 1 "S" or "C"
WBC [×103/µL]			 5 XXX.XF
RBC [×106/µL]			 5 XX.XXF
HGB [g/dL]				 5 XXX.XF
HCT [%]					 5 XXX.XF
MCV [fL]				 5 XXX.XF
MCH [pg]				 5 XXX.XF
MCHC [g/dL]				 5 XXX.XF
PLT [×103/µL]			 5 XXXXF
LYM% (W-SCR) [%]		 5 XXX.XF
MXD% (W-MCR) [%]		 5 XXX.XF
NEUT% (W-LCR) [%]		 5 XXX.XF
LYM# (W-SCC) [×103/µL]	 5 XXX.XF
MXD# (W-MCC) [×103/µL]	 5 XXX.XF
NEUT# (W-LCC) [×103/µL]	 5 XXX.XF
RDW-SD/CV [fL/%]		 5 XXX.XF
PDW [fL]				 5 XXX.XF
MPV [fL]				 5 XXX.XF
P-LCR [%]				 5 XXX.XF
*/

declare @s table(val varchar(32)
	,mes varchar(32)
	,l int
	,float_pos int
	,descr varchar(32))

insert into @s (val,mes,float_pos,l,descr)
values
('Text distinction code I'	,null,null	,1 ,'"D"')
,('Text distinction code ll',null,null	,1 ,'"1"')
,('Sample distinction code'	,null,null	,1 ,'"U"')
,('Year (Month or Day)'		,null,null	,2 ,'"97"')
,('Month (or Day)'			,null,null	,2 ,'"09"')
,('Day (or Year)'			,null,null	,2 ,'"30"')
,('Analysis information'	,null,null	,1 ,'(O)')
,('Sample ID No.'			,null,null	,12,'(OOOOOOOOOOOO)')
,('PDA information'			,null,null	,6 ,'(OOOOOO)')
,('RDW select information',null	 ,null	,1 ,'"S" or "C"')
,('WBC',			'[x103/µL]'	 ,3		,5 ,'XXX.XF')
,('RBC',			'[x106/µL]'	 ,2		,5 ,'XX.XXF')
,('HGB',			'[g/dL]'	 ,4		,5 ,'XXX.XF')
,('HCT',			'[%]'		 ,1		,5 ,'XXX.XF')
,('MCV',			'[fL]'		 ,3		,5 ,'XXX.XF')
,('MCH',			'[pg]'		 ,3		,5 ,'XXX.XF')
,('MCHC',			'[g/dL]'	 ,4		,5 ,'XXX.XF')
,('PLT',			'[x103/µL]'	 ,4		,5 ,'XXXXF	')
,('LYM% (W-SCR)',	'[%]'		 ,1		,5 ,'XXX.XF')
,('MXD% (W-MCR)',	'[%]'		 ,1		,5 ,'XXX.XF')
,('NEUT% (W-LCR)',	'[%]'		 ,1		,5 ,'XXX.XF')
,('LYM# (W-SCC)',	'[x103/µL]'	 ,3		,5 ,'XXX.XF')
,('MXD# (W-MCC)',	'[x103/µL]'	 ,3		,5 ,'XXX.XF')
,('NEUT# (W-LCC)',	'[x103/µL]'	 ,3		,5 ,'XXX.XF')
,('RDW-SD/CV',		'[fL/%]'	 ,3		,5 ,'XXX.XF')
,('PDW',			'[fL]'		 ,3		,5 ,'XXX.XF')
,('MPV',			'[fL]'		 ,3		,5 ,'XXX.XF')
,('P-LCR',			'[%]'		 ,1		,5 ,'XXX.XF')

select
@l=isnull(SUM(l),0)
,@data_len=isnull(LEN(@data),0)
from @s

declare @ERRNO int, @ERRMSG  varchar(255)

if(@l<>@data_len)
	select @ERRNO = 50001, @ERRMSG  ='Incorrect message length received '+CONVERT(varchar(32),@data_len)+', waiting for '+CONVERT(varchar(32),@l)
	
if(@ERRNO>0)
     raiserror @ERRNO @ERRMSG 
else
begin	

select @pos=1

DECLARE cur CURSOR 
FOR
-----------
select
val,mes,l,float_pos,descr
from @s
----------
OPEN Cur;
FETCH NEXT FROM Cur into 
	@val_name,@mes,@l,@float_pos,@descr
WHILE @@FETCH_STATUS = 0
	BEGIN
	---------------------------------
	select @v_str=case when @float_pos>0 then SUBSTRING(@data,@pos,@float_pos)+'.'+SUBSTRING(@data,@pos+@float_pos,@l-@float_pos) end 
	select @val_name+' '+isnull(@mes,'')
	,case when ISNUMERIC(@v_str)=1 then convert(real,@v_str) end
	,SUBSTRING(@data,@pos,@l)
	
	select @pos=@pos+@l
	---------------------------------
	FETCH NEXT FROM Cur into 
	@val_name,@mes,@l,@float_pos,@descr
	END;
CLOSE Cur;
DEALLOCATE Cur;			

end