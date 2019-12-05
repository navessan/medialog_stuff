disable trigger all on FM_BILLDET
GO

declare @BILL_DATE_START datetime
declare @BILL_DATE_END datetime

set @BILL_DATE_START = '2011-01-01 00:00:00.000'
set @BILL_DATE_END = '2011-02-01 00:00:00.000'

update FM_BILLDET
set FM_BILLDET.PRICE = FM_SERVPRICE.PRICE
from FM_BILLDET FM_BILLDET
inner join FM_BILL FM_BILL
	on FM_BILLDET.FM_BILL_ID = FM_BILL.FM_BILL_ID
inner join FM_SERVPRICE FM_SERVPRICE
	on FM_BILLDET.FM_SERV_ID = FM_SERVPRICE.FM_SERV_ID and
	   FM_BILLDET.FM_PRICETYPE_ID = FM_SERVPRICE.FM_PRICETYPE_ID and
	   FM_BILLDET.FM_DEVISE_ID = FM_SERVPRICE.FM_DEVISE_ID and
	   FM_SERVPRICE.DATE_FROM =
			(select max (FM_SERVPRICE_SUB.DATE_FROM)
			 from FM_SERVPRICE FM_SERVPRICE_SUB
			 where FM_SERVPRICE_SUB.DATE_FROM < FM_BILL.BILL_DATE and
				   FM_BILLDET.FM_SERV_ID = FM_SERVPRICE_SUB.FM_SERV_ID and
				   FM_BILLDET.FM_PRICETYPE_ID = FM_SERVPRICE_SUB.FM_PRICETYPE_ID and
				   FM_BILLDET.FM_DEVISE_ID = FM_SERVPRICE_SUB.FM_DEVISE_ID)
where FM_BILL.BILL_DATE between @BILL_DATE_START and @BILL_DATE_END
	  -- and FM_BILL.MEDECINS1_ID in (360, 361)		-- ���� ������
	  and FM_BILL.FM_DEP_ID in (15)					-- ������������� ������

GO

enable trigger all on FM_BILLDET
GO