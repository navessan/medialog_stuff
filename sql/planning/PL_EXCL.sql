declare @PL_SUBJ_ID int
set	@PL_SUBJ_ID=420

select * 
from PL_excl 
where 
PL_SUBJ_ID in(@PL_SUBJ_ID)
--and TO_DATE>getdate()