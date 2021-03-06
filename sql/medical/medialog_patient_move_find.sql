--база данных
use medialog7_back

declare @current_pat int
		,@new_pat_id int
		,@backup_pat_id int
		,@MOTCONSU_ID int
select
	@current_pat=407760		--текущий объединенный пациент
	,@new_pat_id=839546		--куда переносим записи в текущей базе
	,@backup_pat_id=407841	--удаленный пациент

--
select 
case 
when old.PATIENTS_ID=@backup_pat_id then 'санина'
when old.PATIENTS_ID=@current_pat then 'василенко'
when old.PATIENTS_ID is null then 'санина'
end my
,
old.PATIENTS_ID old_PATIENTS_ID, old_pat.nom old_nom,
new.PATIENTS_ID new_PATIENTS_ID, new_pat.nom new_nom,
new.* 
from medialog7.dbo.motconsu new
join medialog7.dbo.patients new_pat on new_pat.PATIENTS_ID=new.PATIENTS_ID
left join medialog7_back.dbo.motconsu old on new.MOTCONSU_ID = old.MOTCONSU_ID
left join medialog7_back.dbo.patients old_pat on old_pat.PATIENTS_ID=old.PATIENTS_ID
where
new.PATIENTS_ID=@current_pat
--пациент в текущей базе с фамилией от удаленного пациента
and old.PATIENTS_ID=new.PATIENTS_ID	
order by old.PATIENTS_ID,new.date_consultation