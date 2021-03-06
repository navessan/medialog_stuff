declare @P1 int
declare @cod varchar(20)
declare @name varchar(200)
--таблица куда импортируются данные
declare @KeyName varchar(30)
set @KeyName='OMS_STREET_NEW'


--запрос для импорта данных с проверкой дублирования
--DECLARE data_Cursor CURSOR FOR

SELECT msk.code ,msk.[name]
/*,msk.*
,'|' '|'
,StreetOnTerrUnit.codeterrunit
,TerrUnit.name
,Terr.name
,'|' '|'
,distr.*
,'|' '|'
--,msk.*
,'|' '|'
,settlement.*
*/
  FROM us_MskOMS_Street msk
/*left join us_MskOMS_StreetOnTerrUnit StreetOnTerrUnit on msk.code=StreetOnTerrUnit.CodeStreet
left join us_MskOMS_TerrUnit TerrUnit on TerrUnit.Code=StreetOnTerrUnit.CodeTerrUnit
left join z_MskOMS_StreetOnTerr StreetOnTerr on msk.code=StreetOnTerr.CodeStreet
left join z_MskOMS_Terr Terr on Terr.Code=StreetOnTerr.CodeTerr

left join us_NSI_District distr on 
		distr.CodeRegion=msk.KLADRCodeRegion and
		distr.CodeDistrict=msk.KLADRCodeDistrict and 
		distr.PrAkt=msk.KLADRPrAkt
left join us_nsi_settlement Settlement on 
		settlement.CodeRegion=msk.KLADRCodeRegion and
		settlement.CodeDistrict=msk.KLADRCodeDistrict and 
		settlement.CodeSettlement=msk.KLADRCodeSettlement and 
		settlement.PrAkt=msk.KLADRPrAkt*/
where msk.code not in(select codfond from OMS_STREET_NEW)
--where msk.code='63692'
--and msk.name not in(select [name] from OMS_STREET_NEW)
--group by msk.name, msk.code
order by msk.name

--having count(msk.name)>1

/*
--построчный импорт с установкой ID
OPEN data_Cursor;
FETCH NEXT FROM data_Cursor into @cod,@name;
WHILE @@FETCH_STATUS = 0
   BEGIN
		exec up_get_id  @KeyName, @Shift = 1, @ID = @P1 output
		insert into OMS_STREET_NEW
				(OMS_STREET_NEW_id,codfond,[name])
			values(@p1,@cod,@name)
      FETCH NEXT FROM data_Cursor into @cod,@name;
   END;
CLOSE data_Cursor;

DEALLOCATE data_Cursor;
*/
--конец

