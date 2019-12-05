sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'Ole Automation Procedures', 1;  
GO  
RECONFIGURE;  
GO 

declare 
	@debug int
	,@params varchar(8000)
	,@res_status int
	,@response varchar(8000)
	,@tid varchar(128)
	,@cid varchar(128)
	,@ti int
	,@tr money

select @debug=0

select @tid='UA-123456-1'
		--,@cid='1592065166.1512119237'
		,@cid='dc925a2b-ca98-4a1b-be19-fe173d0b451f'
		,@ti=12402
		,@tr=510

SET @params = 'v=1'									--// Version. //����
SET @params = @params + '&tid='+@tid				--// Tracking ID / Property ID. //����
SET @params = @params + '&cid='+@cid				--// Anonymous Client ID. //����
SET @params = @params + '&t=transaction'			--// Transaction hit type. //����
SET @params = @params + '&ti='+ cast(@ti as varchar(32))			--// transaction ID. Required. //����. ���������� ���� ���������� �����
SET @params = @params + '&ta=med2'				--// Transaction affiliation. // �����. ��� ����� "����� ������" ������� ��������
SET @params = @params + '&tr='+ cast(@tr as varchar(32))			--// Transaction revenue. //����
SET @params = @params + '&cu=RU'					--// Currency code. // ����. �� ���� RUB
SET @params = @params + '&dh=10.255.69.241&uip=192.168.1.10&ua=wget'
set @params = @params + '&z='+cast(datediff(SECOND,'20180101',getdate())as varchar(32))

--exec dbo.US_WEB_GA_POST @params, @res_status out, @response out, @debug
exec dbo.US_WEB_GA_GET @params, @res_status out, @response out, @debug

if(@res_status>=200 and @res_status<300)
begin

	SET @params = 'v=1'								--// Version.   //����
	SET @params = @params + '&tid='+ @tid				--// Tracking ID / Property ID.   //����
	SET @params = @params + '&cid='+ @cid				--// Anonymous Client ID.   //����			  --
	SET @params = @params + '&t=item'				--// Item hit type.   //����
	SET @params = @params + '&ti='+ cast(@ti as varchar(32))         --// Transaction ID. Required.   //����. ����� ��, ��� � ����
	SET @params = @params + '&in=depozit'			--// Item name. Required.   //����
	SET @params = @params + '&ip='+ cast(@tr as varchar(32))           --// Item price.   //����
	SET @params = @params + '&iq=1'					--// Item quantity.   //����
--	SET @params = @params + '&ic=u3eqds43'			--// Item code / SKU. //�����. ���� ����
	SET @params = @params + '&iv=gosp'				--// Item variation / category.   //����
	SET @params = @params + '&cu=RU'				--// Currency code.   //���� 
	SET @params = @params + '&dh=10.255.69.241&uip=192.168.1.10&ua=wget'
	set @params = @params + '&z='+cast(datediff(SECOND,'20180101',getdate())as varchar(32))

	--exec dbo.US_WEB_GA_POST @params, @res_status out, @response out, @debug
	exec dbo.US_WEB_GA_GET @params, @res_status out, @response out, @debug
end
else
	select 'error'as a, @res_status as res, @response as response
-----------------------
GO  
sp_configure 'Ole Automation Procedures', 0;  
GO  
RECONFIGURE;