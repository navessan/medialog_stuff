sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'Ole Automation Procedures', 1;  
GO  
RECONFIGURE;  
GO 

declare 
	@params varchar(8000)
	,@res_status int
	,@response varchar(8000)
	,@tid varchar(128)
	,@cid varchar(128)
	,@ti int
	,@tr money

select @tid='UA-123456-1'
		,@cid='1592065166.1512119237'
		,@ti=12363
		,@tr=580

SET @params = 'v=1'									--// Version. //ÍÀÄÎ
SET @params = @params + '&tid='+@tid				--// Tracking ID / Property ID. //ÍÀÄÎ
SET @params = @params + '&cid='+@cid				--// Anonymous Client ID. //ÍÀÄÎ
SET @params = @params + '&t=transaction'			--// Transaction hit type. //ÍÀÄÎ
SET @params = @params + '&ti='+ cast(@ti as varchar(32))			--// transaction ID. Required. //ÍÀÄÎ. Ãåíåğèğóåì ñàìè óíèêàëüíûé íîìåğ
SET @params = @params + '&ta=medialog'				--// Transaction affiliation. // Ìîæíî. Òóò ìîæíî "òî÷êó ïğîäàæ" íàçâàòü Ìåäèàëîã
SET @params = @params + '&tr='+ cast(@tr as varchar(32))			--// Transaction revenue. //ÍÀÄÎ
SET @params = @params + '&cu=RUB'					--// Currency code. // ÍÀÄÎ. Ïî èäåå RUB

exec dbo.US_WEB_GA_POST @params, @res_status out, @response out
--exec dbo.US_WEB_GA_GET @params, @res_status out, @response out

if(@res_status>=200 and @res_status<300)

begin

	SET @params = 'v=1'								--// Version.   //ÍÀÄÎ
	SET @params = @params + '&tid='+ @tid				--// Tracking ID / Property ID.   //ÍÀÄÎ
	SET @params = @params + '&cid='+ @cid				--// Anonymous Client ID.   //ÍÀÄÎ			  --
	SET @params = @params + '&t=item'				--// Item hit type.   //ÍÀÄÎ
	SET @params = @params + '&ti='+ cast(@ti as varchar(32))         --// Transaction ID. Required.   //ÍÀÄÎ. Òàêîé æå, êàê è âûøå
	SET @params = @params + '&in=depozit'			--// Item name. Required.   //ÍÀÄÎ
	SET @params = @params + '&ip='+ cast(@tr as varchar(32))           --// Item price.   //ÍÀÄÎ
	SET @params = @params + '&iq=1'					--// Item quantity.   //ÍÀÄÎ
--	SET @params = @params + '&ic=u3eqds43'			--// Item code / SKU. //ÌÎÆÍÎ. Åñëè åñòü
	SET @params = @params + '&iv=gosp'				--// Item variation / category.   //ÍÀÄÎ
	SET @params = @params + '&cu=RUB'				--// Currency code.   //ÍÀÄÎ 
	
	exec dbo.US_WEB_GA_POST @params, @res_status out, @response out
	--exec dbo.US_WEB_GA_GET @params, @res_status out, @response out
end
else
	select @res_status as res, @response as response
-----------------------
GO  
sp_configure 'Ole Automation Procedures', 0;  
GO  
RECONFIGURE;