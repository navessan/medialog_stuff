
--SELECT TOP 50 *
declare @pat int
set @pat=9736


/*
update DIR_ANSW set
MOTCONSU_RESP_ID=null, PLANNING_ID=null, FM_BILL_ID= null

where PATDIREC_ID in 
(select PATDIREC_ID from PATDIREC
where
PATIENTS_ID =@pat
)


delete
--
--select *
 from DIR_ANSW 
where PATDIREC_ID in 
(select PATDIREC_ID from PATDIREC
where
PATIENTS_ID =@pat
)
*/

update PATDIREC set
PLANNING_CR_ID=null
where
PATIENTS_ID =@pat

delete
 from PATDIREC
where
PATIENTS_ID =@pat


delete
from planning
where
PATIENTS_ID =@pat
