
declare @PL_EX_GR_ID int
set @PL_EX_GR_ID=41
/*
--проверяем
SELECT TOP 5000
 PL_EXAM.code
 ,pl_exam.NAME
 ,PL_EXAM.ARCHIVE
 ,fm_serv.CODE
 ,fm_serv.LABEL
 ,FM_DIR_SERV.FM_DIR_SERV_ID
FROM
 PL_EXAM PL_EXAM 
 LEFT OUTER JOIN PL_EX_GR PL_EX_GR ON PL_EX_GR.PL_EX_GR_ID = PL_EXAM.PL_EX_GR_ID 
 join fm_serv on fm_serv.fm_serv_id=pl_exam.fm_serv_id
 left join FM_DIR_SERV on PL_EXAM.PL_EXAM_ID=FM_DIR_SERV.PL_EXAM_ID
WHERE
fm_serv.STATE='A' and
PL_EXAM.PL_EX_GR_ID in (@PL_EX_GR_ID)
*/

--кидаем в архив старые
update pl_exam set PL_EXAM.ARCHIVE=1
FROM
 PL_EXAM PL_EXAM 
 LEFT OUTER JOIN PL_EX_GR PL_EX_GR ON PL_EX_GR.PL_EX_GR_ID = PL_EXAM.PL_EX_GR_ID 
 join fm_serv on fm_serv.fm_serv_id=pl_exam.fm_serv_id
 left join FM_DIR_SERV on PL_EXAM.PL_EXAM_ID=FM_DIR_SERV.PL_EXAM_ID
WHERE
fm_serv.STATE='H' and
PL_EXAM.PL_EX_GR_ID in (@PL_EX_GR_ID)


--обновляем параметры активных направлений
 update PL_EXAM set NEED_EDIT=0,NEED_COMMENTS=0, NAME=fm_serv.LABEL
FROM
 PL_EXAM PL_EXAM 
 LEFT OUTER JOIN PL_EX_GR PL_EX_GR ON PL_EX_GR.PL_EX_GR_ID = PL_EXAM.PL_EX_GR_ID 
 join fm_serv on fm_serv.fm_serv_id=pl_exam.fm_serv_id
 left join FM_DIR_SERV on PL_EXAM.PL_EXAM_ID=FM_DIR_SERV.PL_EXAM_ID
WHERE
fm_serv.STATE='A' and
PL_EXAM.PL_EX_GR_ID in (@PL_EX_GR_ID)

--удаляем связанные услуги для направлений привязынных к услугам через pl_exam.fm_serv_id

delete from FM_DIR_SERV
where FM_DIR_SERV_ID in(

SELECT
 FM_DIR_SERV.FM_DIR_SERV_ID
 FROM
 PL_EXAM PL_EXAM 
 join fm_serv on fm_serv.fm_serv_id=pl_exam.fm_serv_id
 join FM_DIR_SERV on PL_EXAM.PL_EXAM_ID=FM_DIR_SERV.PL_EXAM_ID
WHERE
fm_serv.STATE='A' and
PL_EXAM.PL_EX_GR_ID in (@PL_EX_GR_ID)

)


/*
update fm_serv set
fm_serv.STATE='A'
from FM_SERV
 join PL_EXAM PL_EXAM on fm_serv.fm_serv_id=pl_exam.fm_serv_id
WHERE
fm_serv.STATE='H' and
PL_EXAM.PL_EX_GR_ID in (45)  


update fm_serv set
fm_serv.STATE='A'
from FM_SERV
 join FM_DIR_SERV on fm_serv.fm_serv_id=FM_DIR_SERV.fm_serv_id
 join PL_EXAM PL_EXAM on PL_EXAM.PL_EXAM_ID=FM_DIR_SERV.PL_EXAM_ID

WHERE
fm_serv.STATE='H' and
PL_EXAM.PL_EX_GR_ID in (45)

*/

