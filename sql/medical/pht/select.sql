select
PR_TEMPLATE_SCHEMES.PR_TEMPLATE_SCHEMES_ID,
PATDIREC.PATDIREC_ID,
PR_TEMPLATE_SCHEMES.FULL_NAME,
PATDIREC.COMMENTAIRE,
PATDIREC.QUANTITY,
PATDIREC_DRUGS.DOSE,
PATDIREC_DRUGS_DET.PR_DRUGS_ID,
pl_exam.PRINT_MEMO
,'|' '|',
PATDIREC.*
,PATDIREC_DRUGS.*

from PR_TEMPLATE_SCHEMES
join PATDIREC on PR_TEMPLATE_SCHEMES.PR_TEMPLATE_SCHEMES_ID=PATDIREC.PR_TEMPLATE_SCHEMES_ID
join PL_EXAM on PATDIREC.PL_EXAM_ID=PL_EXAM.PL_EXAM_ID
join PATDIREC_DRUGS on PATDIREC.PATDIREC_ID=PATDIREC_DRUGS.PATDIREC_ID
join PATDIREC_DRUGS_DET on PATDIREC_DRUGS.PATDIREC_DRUGS_ID=PATDIREC_DRUGS_DET.PATDIREC_DRUGS_ID
where
 PR_TEMPLATE_SCHEMES.PR_TEMPLATE_SCHEMES_ID =1301
 
order by PATDIREC.PATDIREC_ID
