declare @MOTCONSU_ID as integer
--set @MOTCONSU_ID=:@MOTCONSU.MOTCONSU_ID
set @MOTCONSU_ID=2565624

declare @serv_code as varchar(32), @serv_label as varchar(64)
declare @serv_code_res as varchar(256), @serv_label_res as varchar(256)
declare @serv_all as varchar(256)
declare @cnt as int

set @serv_code_res=''
set @serv_label_res=''
set @serv_all=''

DECLARE cur CURSOR FOR
SELECT 
FM_SERV.CODE,FM_SERV.LABEL, FM_BILLDET.CNT
FROM FM_BILL FM_BILL 
JOIN FM_BILLDET FM_BILLDET ON FM_BILL.FM_BILL_ID = FM_BILLDET.FM_BILL_ID 
LEFT OUTER JOIN FM_SERV FM_SERV ON FM_SERV.FM_SERV_ID = FM_BILLDET.FM_SERV_ID 
WHERE FM_BILL.MOTCONSU_ID = @MOTCONSU_ID

OPEN Cur;
FETCH NEXT FROM Cur into @serv_code, @serv_label, @cnt;
WHILE @@FETCH_STATUS = 0
   BEGIN
		if(len(@serv_code_res)>0 and len(@serv_code)>0)
			set @serv_code_res=@serv_code_res+', '
		set @serv_code_res=@serv_code_res+isnull(@serv_code,'')+ ' - '+convert(varchar,@cnt)
		
		if(len(@serv_label_res)>0 and len(@serv_label)>0)
			set @serv_label_res=@serv_label_res+', '
		set @serv_label_res=@serv_label_res+isnull(@serv_label,'')

		if(len(@serv_all)>0)
			set @serv_all=@serv_all+', '
		set @serv_all=@serv_all+isnull(@serv_code,'')+' '+isnull(@serv_label,'')
      FETCH NEXT FROM Cur into @serv_code, @serv_label, @cnt;
   END;
CLOSE Cur;
DEALLOCATE Cur;

--select @serv_code_res serv_code_res, @serv_label_res serv_label_res, @serv_all serv_all
--select @serv_all serv_all
select @serv_code_res serv_code_res

UPDATE DATA197
   SET USLUGI_IZ_TALONA=@serv_code_res
 WHERE MOTCONSU_ID=@MOTCONSU_ID

