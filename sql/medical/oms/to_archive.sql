/*select code,label
,reesus.cod
,reesus.name
*/
update fm_serv set
code=code+'.арх140101'
,state='H'

from fm_serv
left join  [medialog7].[dbo].[z_reesus42] reesus on reesus.cod=code and reesus.name=label
where code like 'о%'
and state<>'H'
and reesus.cod is null