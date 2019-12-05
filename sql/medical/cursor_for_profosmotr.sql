declare @patient as integer
set @patient=160918
--:@PATIENTS.PATIENTS_ID

declare @work_code as varchar(32), @factor_code as varchar(32)
declare @work_code_res as varchar(32), @factor_code_res as varchar(256)

set @work_code_res=''
set @factor_code_res=''

DECLARE cur CURSOR FOR
select us_prof_work.code work_code
,us_prof_factors.code factor_code
from data306
left outer join us_prof_factors on us_prof_factors.us_prof_factors_id=VREDNYY_FAKTOR 
left outer join us_prof_work on us_prof_work.us_prof_work_id=PROFESSIYA
where data306.patients_id=@patient

OPEN Cur;
FETCH NEXT FROM Cur into @work_code, @factor_code;
WHILE @@FETCH_STATUS = 0
   BEGIN
		if(len(@work_code_res)>0 and len(@work_code)>0)
			set @work_code_res=@work_code_res+', '
		set @work_code_res=@work_code_res+isnull(@work_code,'')
		if(len(@factor_code_res)>0 and len(@factor_code)>0)
			set @factor_code_res=@factor_code_res+', '
		set @factor_code_res=@factor_code_res+isnull(@factor_code,'')
      FETCH NEXT FROM Cur into @work_code, @factor_code;
   END;
CLOSE Cur;
DEALLOCATE Cur;

select @work_code_res work_code_res, @factor_code_res factor_code_res

update data305
set
VREDNYE_FAKTORY=@factor_code_res
,PROFESSIYA_IZ_PERECHNYA=@work_code_res
where data305.patients_id=@patient