update metatable
set metatable.custom=('Label='+z.[cl_kod]+' '+substring(metatable.TABLE_NAME,len('US_OMS_CL010'),2)+' '+replace(ltrim(rtrim((z.[cl_name]))),'"','')+ CHAR(13)+CHAR(10) +'GlossTable=1')

/*SELECT 
z.*
,metatable.*
,('Label='+z.[cl_kod]+' '+substring(metatable.TABLE_NAME,len('US_OMS_CL010'),2)+' '+replace(ltrim(rtrim((z.[cl_name]))),'"','')) new_custom*/
  FROM [medialog7].[dbo].[z_cl_description] z
left join metatable on (metatable.TABLE_NAME like('US_OMS_'+z.[cl_kod]+'%'))
