select code,label
,reesus.cod
,reesus.name
from fm_serv
full join  [z_reesus42] reesus on reesus.cod=code and reesus.name=label
where 
 fm_serv.code is null