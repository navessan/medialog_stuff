INSERT INTO [dbo].[IMPDATA]
([Impdata_ID]
,[ImpDeleted]
,[ImpType]
,[Nom]
,[Prenom]
,[Date_Consultation]
,[File_Data]
,[Mesure]
,[PatientImported]
,[KEYCODE]
,[PATIENTS_ID]
,[STATE]
,[MSG_TYPE]
,[QC_INFO]
,[LAB_CONTS_ID]
,[LAB_BIOTYPE_ID])
VALUES (
@impdataId
, 0 --ImpDeleted
, null --ImpType
, null --Nom
, null --Prenom
, GETDATE()
, null --File_Data
, 'ÖÌÄ' --Mesure
, @motconsu_id --PatientImported
, @bioCode --KEYCODE (biocode)	 select BIO_CODE bCode from PATDIREC where PATDIREC_ID =@patdirec_id
, @patientsId
, null --STATE
, D --MSG_TYPE
, 0 --QC_INFO
, null --LAB_CONTS_ID
, null ) --LAB_BIOTYPE_ID


