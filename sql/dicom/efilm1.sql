/*
SELECT Patient.[PatientID]
      ,Patient.[PatientsName]
      ,Patient.[PatientsBirthDate]
      ,Patient.[PatientsSex]
      ,Patient.[PatientUID]

      ,Study.[StudyInstanceUID]
      ,Study.[StudyDate]
      ,Study.[StudyID]
      ,Study.[AccessionNumber]
      ,Study.[Modality]

,Series.SeriesNumber
,[ProtocolName]
,[SeriesDescription]
,SeriesInstanceUID
,[FrameOfReferenceUID]
,(select count(*) from Image where Image.SeriesInstanceUID=Series.SeriesInstanceUID) imagesCount
  FROM Patient
join Study on Study.PatientUID=Patient.PatientUID
join Series on Study.StudyInstanceUID=ReferencedStudyComponent
--where Patient.PatientID like '69%'
*/

SELECT top 1
Patient.[PatientID]
      ,Patient.[PatientsName]
      ,Patient.[PatientsBirthDate]
      ,Patient.[PatientsSex]
      ,Patient.[PatientUID]

      ,Study.[StudyInstanceUID]
      ,Study.[StudyDate]
      ,Study.[StudyID]
      ,Study.[AccessionNumber]
      ,Study.[Modality]

,Series.SeriesNumber
,Series.ProtocolName
,Series.SeriesDescription
,Series.SeriesInstanceUID
,Series.FrameOfReferenceUID
,SOPInstanceUID

  FROM Patient
join Study on Study.PatientUID=Patient.PatientUID
join Series on Study.StudyInstanceUID=ReferencedStudyComponent
join Image on Image.SeriesInstanceUID=Series.SeriesInstanceUID
where Image.SeriesInstanceUID='1.2.392.200036.9116.2.6.1.16.1613468930.1328003167.278031'


SELECT top 1
[SOPInstanceUID]
      ,[SeriesInstanceUID]
      ,[StudyInstanceUID]
,FrameOfReferenceUID
  FROM [eFilmWorkstation].[dbo].[Image]

/*
SELECT top 10 
[SOPInstanceUID]
      ,[SeriesInstanceUID]
      ,[StudyInstanceUID]
,*
  FROM [eFilmWorkstation].[dbo].[Image]

SELECT top 10 *
  FROM series

SELECT top 10 *
  FROM study
*/