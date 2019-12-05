select MEDICINSKAQ_KARTA, _count 
from (
select MEDICINSKAQ_KARTA
,count (MEDICINSKAQ_KARTA) _count
 from patients
where KOMMENTARIJ_K_AR_IVU is null --and GOD_AR_IVA is null
group by MEDICINSKAQ_KARTA
--order by count desc
) as a
where _count>2 
order by _count desc