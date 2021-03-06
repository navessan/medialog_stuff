USE [medialog7]
GO
/****** Object:  UserDefinedFunction [dbo].[PatientParseAddress]    Script Date: 03/13/2012 18:15:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER  function [dbo].[PatientParseAddress] (@patients_id int)
returns varchar(255)
AS
BEGIN
	declare @res as varchar(255)

	set @res=null

	if(@patients_id is null)
		return null

	set @res=(
-----------------------------------------------------------------------
select top 1
case when (PATIENTS.MOSKVA=1 /*or OMS_OBLAST.OBLAST_CODE='77' */) then 
    'Москва' +', '+
    (select top 1 name from OMS_STREET_NEW
				where OMS_STREET_NEW_ID=PATIENTS.ULICA_MOSKVA_NOVOE)
else
	OMS_OBLAST.OBLAST_NAME+
	case when len(PATIENTS.RAJON)>0 then ', '+PATIENTS.RAJON else '' end+ 
	case when len(PATIENTS.GOROD)>0 then ', '+PATIENTS.GOROD else '' end+
	case when len(PATIENTS.ULICA)>0 then ', '+PATIENTS.ULICA else '' end
end+

case when len(PATIENTS.DOM)>0 then  ', д '+ PATIENTS.DOM else '' end+
case when len(PATIENTS.STROENIE)>0 then  ', стр '+  PATIENTS.STROENIE else '' end+
case when len(PATIENTS.KORPUS  )>0 then  ', кор '+  PATIENTS.KORPUS  else '' end+
case when len(PATIENTS.KVARTIRA  )>0 then  ', кв '+  PATIENTS.KVARTIRA  else '' end+
case when len(PATIENTS.TEL)>0 then  ', тел '+  PATIENTS.TEL else '' end
from patients
 LEFT OUTER JOIN OMS_OBLAST OMS_OBLAST ON OMS_OBLAST.OMS_OBLAST_ID = PATIENTS.KOD_TERRITORII 
where 
patients_id=@patients_id
-----------------------------------------------------------------------------
)

	set @res=rtrim(ltrim(@res))

  return @res
END
