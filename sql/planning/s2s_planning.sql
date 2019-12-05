 

select
top 50
  pl.PLANNING_ID as ScheduleId
, pl.DATE_CONS as VisitDate
,pl.DATE_START as VisitBeginTime
,pl.DATE_END as VisitEndTime
, p.PATIENTS_ID as PATIENT_ID	-- Пациент
, isnull(p.NOM, '') + ' ' + isnull(p.PRENOM, '') + ' ' +  isnull(p.PATRONYME, '') as PatientFullName
, coalesce(p.TEL,p.MOBIL_TELEFON) as PatientPhone
, m.medecins_id as DoctorId
, isnull(m.nom, '') + ' ' + isnull(m.prenom, '') as DoctorFullName
, m.SPECIALISATION_ID as SpecId
, m.specialisation as SpecName -- Специальность врача
, sj.pl_subj_id as SUBJ_ID
, sj.NAME as SUBJ_NAME	-- Расписание
, ex.NAME as EXAM_NAME	-- Вид приема
from planning pl 
join patients p on pl.PATIENTS_ID = p.PATIENTS_ID
join pl_exam ex on ex.pl_exam_id = pl.pl_exam_id
join pl_subj sj on sj.pl_subj_id = pl.pl_subj_id
left outer join medecins m on m.medecins_id = sj.medecins_id
where  
isnull(pl.CANCELLED, 0) = 0
and isnull(pl.STATUS, 0) = 0
and isnull(pl.NOT_ACCEPTED, 0)=0
-- and DATE_CONS=@
order by planning_id desc