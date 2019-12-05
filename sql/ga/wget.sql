
-- enable xp_cmdshell
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1
RECONFIGURE
GO

Declare @Reponse as Varchar(8000)
Declare 
	@target varchar(256)
	,@url VARCHAR(3000)

declare 	
	@debug int
	,@prog varchar(128)
	,@cmd varchar(8000)
	,@params varchar(8000)
	,@res_status int
	,@response varchar(8000)
	,@tid varchar(128)
	,@cid varchar(128)
	,@ti int
	,@tr money


select @debug=0

SET @target = 'http://www.google-analytics.com/collect'
if @debug=1
	SET @target = 'http://www.google-analytics.com/debug/collect'
if @debug=2
	SET @target = 'http://10.255.69.241:81/collect'

select @prog='C:\soft\wget\wget.exe --no-check-certificate --quiet -O -'


select @tid='UA-123456-1'
		,@cid='1592065166.1512119237'
		--,@cid='dc925a2b-ca98-4a1b-be19-fe173d0b451f'
		,@ti=datediff(SECOND,'20180201',getdate())
		,@tr=510

SET @params = 'v=1'									--// Version. //НАДО
SET @params = @params + '&tid='+@tid				--// Tracking ID / Property ID. //НАДО
SET @params = @params + '&cid='+@cid				--// Anonymous Client ID. //НАДО
SET @params = @params + '&t=transaction'			--// Transaction hit type. //НАДО
SET @params = @params + '&ti='+ cast(@ti as varchar(32))			--// transaction ID. Required. //НАДО. Генерируем сами уникальный номер
SET @params = @params + '&ta=med2'				--// Transaction affiliation. // Можно. Тут можно "точку продаж" назвать Медиалог
SET @params = @params + '&tr='+ cast(@tr as varchar(32))			--// Transaction revenue. //НАДО
SET @params = @params + '&cu=RU'					--// Currency code. // НАДО. По идее RUB
SET @params = @params + '&dh=10.255.69.241&uip=192.168.1.10&ua=wget'
set @params = @params + '&z='+cast(datediff(SECOND,'20180101',getdate())as varchar(32))

select @url=@target+'?'+@params
select @cmd= @prog+' "'+@url+'"'

select @cmd as cmd
EXEC xp_cmdshell @cmd

if(1=1)
begin

	SET @params = 'v=1'								--// Version.   //НАДО
	SET @params = @params + '&tid='+ @tid				--// Tracking ID / Property ID.   //НАДО
	SET @params = @params + '&cid='+ @cid				--// Anonymous Client ID.   //НАДО			  --
	SET @params = @params + '&t=item'				--// Item hit type.   //НАДО
	SET @params = @params + '&ti='+ cast(@ti as varchar(32))         --// Transaction ID. Required.   //НАДО. Такой же, как и выше
	SET @params = @params + '&in=depozit'			--// Item name. Required.   //НАДО
	SET @params = @params + '&ip='+ cast(@tr as varchar(32))           --// Item price.   //НАДО
	SET @params = @params + '&iq=1'					--// Item quantity.   //НАДО
--	SET @params = @params + '&ic=u3eqds43'			--// Item code / SKU. //МОЖНО. Если есть
	SET @params = @params + '&iv=gosp'				--// Item variation / category.   //НАДО
	SET @params = @params + '&cu=RU'				--// Currency code.   //НАДО 
	SET @params = @params + '&dh=10.255.69.241&uip=192.168.1.10&ua=wget'
	set @params = @params + '&z='+cast(datediff(SECOND,'20180101',getdate())as varchar(32))

	select @url=@target+'?'+@params
	select @cmd= @prog+' "'+@url+'"'

	select @cmd as cmd
	EXEC xp_cmdshell @cmd

end
-----------------------
-- disable xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 0
RECONFIGURE
GO
