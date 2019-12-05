/* TfStatPrm.ReportRequest 'oms_export_ad' */
SELECT DISTINCT 
 (cast (  PATIENTS.PATIENTS_ID  as varchar (36) ) ) PATIENT
,(cast ( 1 as varchar (1) ) ) TIP_ADR
,(cast ( 643 as varchar (3) )) AD_ST
,(cast ( 00 as varchar (2) ) ) CA_C
,(cast (  OMS_OBLAST.OBLAST_CODE  as varchar (2) ) ) C_A
,(cast ( 99 as varchar (2) ) ) RN_C
,(cast (  PATIENTS.RAJON as varchar (80) ) ) RN
,(cast ( case when (PATIENTS.MOSKVA=1 or OMS_OBLAST.OBLAST_CODE='77') then 00 else 99 end as varchar (2) ) ) GOR_C
,(cast (  case when (PATIENTS.MOSKVA=1 or OMS_OBLAST.OBLAST_CODE='77')then '77000000000' else PATIENTS.GOROD end  as varchar (80) ) ) GOR
,(cast ( case when PATIENTS.MOSKVA=1 then 00 else 99 end as varchar (2) ) ) UL_C
,(cast ( (case when PATIENTS.MOSKVA=1 
		then  (select top 1 cl06.code+' '+cl06.name from us_oms_cl0677 cl06 
				inner join OMS_STREET_NEW old on(cl06.code=old.codfond)
				where OMS_STREET_NEW_ID=PATIENTS.ULICA_MOSKVA_NOVOE)
		else  PATIENTS.ULICA end)
 as varchar (80)  )) UL
,(cast ( (case when PATIENTS.MOSKVA=1 
		then  (select top 1 codfond+' '+name from OMS_STREET_NEW
				where OMS_STREET_NEW_ID=PATIENTS.ULICA_MOSKVA_NOVOE)
		else  PATIENTS.ULICA end)
 as varchar (80)  )) old_UL
,(cast (  PATIENTS.DOM  as varchar (10) ) ) DOM
,(cast (  PATIENTS.KORPUS  as varchar (10) ) ) KOR
,(cast (  PATIENTS.STROENIE  as varchar (10) ) ) STR
,(cast (  PATIENTS.KVARTIRA  as varchar (5) ) ) KV
,(cast (  PATIENTS.MODIFY_DATE_TIME  as datetime)) CHD
FROM
 FM_BILL FM_BILL LEFT OUTER JOIN PATIENTS PATIENTS ON PATIENTS.PATIENTS_ID = FM_BILL.PATIENTS_ID 
 LEFT OUTER JOIN OMS_SMO OMS_SMO ON OMS_SMO.OMS_SMO_ID = PATIENTS.SMO 
 LEFT OUTER JOIN OMS_SMO OMS_SMO_1 ON OMS_SMO_1.OMS_SMO_ID = PATIENTS.SMO_REGION 
 LEFT OUTER JOIN OMS_SERPOL OMS_SERPOL ON (PATIENTS.SERIQ_SPR =OMS_SERPOL.OMS_SERPOL_ID)
 LEFT OUTER JOIN OMS_OBLAST OMS_OBLAST ON OMS_OBLAST.OMS_OBLAST_ID = PATIENTS.KOD_TERRITORII 
WHERE
 ((FM_BILL.BILL_DATE >= {ts '2012-01-01 00:00:00.000'} and FM_BILL.BILL_DATE - 1 < {ts '2012-01-31 00:00:00.000'}))
and (PATIENTS.PLATN_J =0 AND PATIENTS.DMS =0 AND PATIENTS.MEDICINSKAQ_KARTA IS NOT NULL)