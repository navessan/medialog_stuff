DECLARE @id int
	,@new_id int
	,@pat_id int
	,@i int
	,@pat_dr_id int
	,@pat_dr_det_id int
	,@current_motconsu_id int
	,@date_consultation datetime
	,@current_user_id int
	,@SHEMA int
	,@N_LINE int
	,@KOEF float
	,@comment varchar(250)
	,@QUANTITY int
	,@DOSE int
	,@PR_DRUGS_ID int
	,@print_memo varchar(max)

declare @ERRNO   int, @ERRMSG  varchar(255)

select 
	@current_motconsu_id=44353 --:%AF_CURRENT_MOTCONSU
	,@current_user_id=787	--:%AF_CURRENT_MEDECIN
	,@pat_id=0
	,@N_LINE=0
	,@ERRNO=0
	,@KOEF=0
	,@comment=''
	,@QUANTITY=0
	,@DOSE=0
	,@PR_DRUGS_ID=null
	,@print_memo=''
 
select @pat_id=PATIENTS_ID
,@date_consultation=date_consultation
 from MOTCONSU 
where MOTCONSU_ID=@current_motconsu_id

select @SHEMA=SHEMA 
,@KOEF=isnull(KOEFFICIENT,1)
from DATA_W716_HIT_SCHEM
where 
MOTCONSU_ID=@current_motconsu_id

if (@SHEMA is null)
     select @ERRNO = 50001, @ERRMSG  ='Не выбрана Схема!'

if(@ERRNO>0)
     raiserror @ERRNO @ERRMSG 
else
begin
---------------------------
/* удаление записей */
delete from DATA_W716_HIT_PROTOCOL
where 
MOTCONSU_ID=@current_motconsu_id
--------------------

DECLARE cur CURSOR FOR
-------------------------
select
PATDIREC.COMMENTAIRE,
PATDIREC.QUANTITY,
PATDIREC_DRUGS.DOSE,
PATDIREC_DRUGS_DET.PR_DRUGS_ID,
pl_exam.PRINT_MEMO
from PR_TEMPLATE_SCHEMES
join PATDIREC on PR_TEMPLATE_SCHEMES.PR_TEMPLATE_SCHEMES_ID=PATDIREC.PR_TEMPLATE_SCHEMES_ID
join PL_EXAM on PATDIREC.PL_EXAM_ID=PL_EXAM.PL_EXAM_ID
join PATDIREC_DRUGS on PATDIREC.PATDIREC_ID=PATDIREC_DRUGS.PATDIREC_ID
join PATDIREC_DRUGS_DET on PATDIREC_DRUGS.PATDIREC_DRUGS_ID=PATDIREC_DRUGS_DET.PATDIREC_DRUGS_ID
where
 PR_TEMPLATE_SCHEMES.PR_TEMPLATE_SCHEMES_ID =@SHEMA
 
order by PATDIREC.PATDIREC_ID
---------------------------------

select @N_LINE=0,@i=0
-------------------------
OPEN Cur;
FETCH NEXT FROM Cur into 
	@comment
	,@QUANTITY
	,@DOSE
	,@PR_DRUGS_ID
	,@print_memo;
WHILE @@FETCH_STATUS = 0
   BEGIN
------------------------------
/*if(@i процент 2=0)
нужен остаток от деления, но знак процента не работает в медиалоге 
*/
if(CEILING(convert(float,@i)/2)=floor(convert(float,@i)/2) )
begin
/* четная строка c нуля, медикамент */
	select 'chet',@comment
	,@QUANTITY
	,@DOSE

exec up_get_id  @KeyName = 'DATA_W716_HIT_PROTOCOL', @Shift = 1, @ID = @new_id output
select @N_LINE=@N_LINE+1

insert into DATA_W716_HIT_PROTOCOL
(DATA_W716_HIT_PROTOCOL_ID
,PATIENTS_ID,DATE_CONSULTATION
,MOTCONSU_ID
,N_LINE
,PREPARAT,DOZA
,DATA
,OSLOZHNENIYA,RASTVOR_DLYA_RAZVEDENIYA
)
values(@new_id
,@pat_id,@date_consultation
,@current_motconsu_id
,@N_LINE
,@comment
,@DOSE*@KOEF
,DATEADD(dd,datediff(dd,0,@date_consultation),0)
,'нет','раствор'
)

end
else
begin
/*
нечетная строка растворитель
*/
update DATA_W716_HIT_PROTOCOL 
set RASTVOR_DLYA_RAZVEDENIYA=@comment+' '+convert(varchar(32),@DOSE)+' мл'
where 
MOTCONSU_ID=@current_motconsu_id and
DATA_W716_HIT_PROTOCOL_ID=@new_id

end

select @i=@i+1
---------------------------------
      FETCH NEXT FROM Cur into 
    @comment
	,@QUANTITY
	,@DOSE
	,@PR_DRUGS_ID
	,@print_memo;
   END;
CLOSE Cur;
DEALLOCATE Cur;
--------------------
select @new_id=null
select @new_id=DATA_PRESCR_AND_RECOMMEND.DATA24_ID
from DATA_PRESCR_AND_RECOMMEND
where 
MOTCONSU_ID=@current_motconsu_id

if (@new_id is null)
begin
	exec up_get_id  @KeyName = 'DATA_PRESCR_AND_RECOMMEND', @Shift = 1, @ID = @new_id output
	insert into DATA_PRESCR_AND_RECOMMEND
	(DATA24_ID,PATIENTS_ID
	,DATE_CONSULTATION,MOTCONSU_ID
	,NAPRAVLENIE_NA_MEDIKO_SOC,DIETIHESKIJ_STOL
	,MEDIKAMENTOZNAQ_TERAPIQ,DRUGIE_NAPRAVLENIQ)
	values(@new_id,@pat_id
	,@date_consultation,@current_motconsu_id
	,0,''
	,'',0
	)
end

update DATA_PRESCR_AND_RECOMMEND
set MEDIKAMENTOZNAQ_TERAPIQ =@print_memo
where 
MOTCONSU_ID=@current_motconsu_id
---------------------------------------

end
