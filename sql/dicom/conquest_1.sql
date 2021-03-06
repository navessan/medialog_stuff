

SELECT [PatientID]
      ,[PatientNam]
,dbo.UTF8_TO_NVARCHAR(PatientNam)
,sys.fn_varbintohexsubstring(1,convert(varbinary(max),PatientNam),1,0)
,cast(convert(varbinary(max),PatientNam) as nvarchar(max))
  FROM [conquest].[dbo].[DICOMPatients]
where PatientNam like char(0xd0)+'%'