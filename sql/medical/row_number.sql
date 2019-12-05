/* TfrmUser.RModels */
select 
m.medmodel_id
,t.*
--update MEDMODEL set ORD=t.o
from medmodel m
join 
(SELECT 
 MEDMODEL.MEDMODEL_ID, MEDMODEL.MEDECINS_ID, MEDMODEL.MODELS_ID
 ,ModeleName, MODELS.CODE, MEDMODEL.ord ORD
 ,row_number() over (order by code,ModeleName) as o
FROM
 MEDMODEL MEDMODEL 
 LEFT OUTER JOIN MODELS MODELS ON MODELS.Models_ID = MEDMODEL.MODELS_ID 
WHERE
 (MEDMODEL.MEDECINS_ID = 250)
--ORDER BY CODE,ModeleName
) as t
on t.MEDMODEL_ID=m.MEDMODEL_ID
WHERE
 (M.MEDECINS_ID = 250)

-- ORDER BY CODE,ModeleName