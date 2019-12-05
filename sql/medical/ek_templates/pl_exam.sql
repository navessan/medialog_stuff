select MAX(patdirec_id)
from PATDIREC
--where PR_TEMPLATE_SCHEMES_ID>0


select distinct 
pl_exam.PL_EXAM_ID
,pl_exam.CODE
,pl_exam.NAME
,pl_ex_gr.NAME
,pl_ex_gr.PL_EX_GR_ID

from [10.255.69.10].[med_euroonco_new].[dbo].PATDIREC
join [10.255.69.10].[med_euroonco_new].[dbo].pl_exam on PATDIREC.PL_EXAM_ID=pl_exam.PL_EXAM_ID
join [10.255.69.10].[med_euroonco_new].[dbo].pl_ex_gr on pl_ex_gr.pl_ex_gr_ID=pl_exam.PL_EX_GR_ID
--left join PL_EXAM as new on pl_exam.PL_EXAM_ID=new.PL_EXAM_ID
where PR_TEMPLATE_SCHEMES_ID>0
--and pl_ex_gr.PL_EX_GR_ID not in (24,25,32,33,38,43,45,46,47,48,49,50,51,52,53)
and pl_ex_gr.PL_EX_GR_ID in (31,160,172,178,202,206,207,208,209)
order by pl_ex_gr.PL_EX_GR_ID

select * from pl_ex_gr

select * from pl_exam
order by PL_EXAM_ID desc


