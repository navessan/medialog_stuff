select patients_ID, nom, MEDICINSKAQ_KARTA
,[KOMMENTARIJ_K_AR_IVU]
from patients where MEDICINSKAQ_KARTA in(
	select MEDICINSKAQ_KARTA from (
		select MEDICINSKAQ_KARTA
		,count (MEDICINSKAQ_KARTA) count
		from patients
		where KOMMENTARIJ_K_AR_IVU is null
		group by MEDICINSKAQ_KARTA
	) as a
	where count>3
)
and KOMMENTARIJ_K_AR_IVU is null
order by MEDICINSKAQ_KARTA