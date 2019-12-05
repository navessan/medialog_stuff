--select patients_ID, nom, MEDICINSKAQ_KARTA,[KOMMENTARIJ_K_AR_IVU],GOD_AR_IVA
update [PATIENTS] set [MEDICINSKAQ_KARTA]=MEDICINSKAQ_KARTA+' '+ convert(varchar,patients_id)
--from patients 
where MEDICINSKAQ_KARTA in(
	select MEDICINSKAQ_KARTA from (
		select MEDICINSKAQ_KARTA
		,count (MEDICINSKAQ_KARTA) count
		from patients
		where KOMMENTARIJ_K_AR_IVU is null --and GOD_AR_IVA is null
		group by MEDICINSKAQ_KARTA
	) as a
	where count>2 and count< 10
)
and KOMMENTARIJ_K_AR_IVU is null and GOD_AR_IVA is null
--order by MEDICINSKAQ_KARTA