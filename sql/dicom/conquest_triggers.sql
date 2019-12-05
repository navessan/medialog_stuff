
create trigger [dbo].[tIU_DICOMPatients] on [dbo].[DICOMPatients] for INSERT,UPDATE as
begin

if update(PatientNam)
	update t set 
	PatientNam = dbo.UTF8_TO_NVARCHAR(i.PatientNam)
	from inserted i, DICOMPatients t
	where i.PatientNam like char(0xd0)+'_'+char(0xd0)+'%'
		and t.PatientID = i.PatientID

end

go

create trigger [dbo].[tIU_DICOMStudies] on [dbo].[DICOMStudies] for INSERT,UPDATE as
begin

if update(PatientNam)
	update t set 
	PatientNam = dbo.UTF8_TO_NVARCHAR(i.PatientNam)
	from inserted i, DICOMStudies t
	where i.PatientNam like char(0xd0)+'_'+char(0xd0)+'%'
		and  t.StudyInsta = i.StudyInsta

end

