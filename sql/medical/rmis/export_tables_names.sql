update metafield
set metafield.custom=('Label='+z_descr.[field_name]+' '+ltrim(rtrim((z_descr.[Назначение поля]))))
/*
SELECT 
--z_descr.*
z_descr.[table]
      ,z_descr.[field_name]
      ,z_descr.[Назначение поля]
	,z_descr.[Ограничения и комментарии]
	,metafield.*
,('Label='+z_descr.[field_name]+' '+ltrim(rtrim((z_descr.[Назначение поля])))) new_custom
*/
  FROM [medialog7].[dbo].[z_descr]
left join metafield on (metafield.TABLE_NAME=('US_OMS_EXPORT_'+z_descr.[table]) and metafield.FIELD_NAME=z_descr.FIELD_NAME)
--order by [table], z_descr.FIELD_NAME