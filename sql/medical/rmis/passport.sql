/* TfStatPrm.ReportRequest 'oms_export_du' */
SELECT DISTINCT 
 (cast (  PATIENTS.PATIENTS_ID  as varchar (36) ) ) PATIENT
,PATIENTS.SERIQ_NOMER_PASPORTA
--,convert(int,substring(replace(replace(PATIENTS.SERIQ_NOMER_PASPORTA,' ',''),'-',''),1,4)) SN
,case when (substring(replace(replace(PATIENTS.SERIQ_NOMER_PASPORTA,' ',''),'-',''),1,10)
		 not like '%[^0-9]%') 
	then substring(replace(replace(PATIENTS.SERIQ_NOMER_PASPORTA,' ',''),'-',''),1,4) 
	else null end s
,case when (substring(replace(replace(PATIENTS.SERIQ_NOMER_PASPORTA,' ',''),'-',''),1,10)
		 not like '%[^0-9]%') 
	then substring(replace(replace(PATIENTS.SERIQ_NOMER_PASPORTA,' ',''),'-',''),5,6) 
	else null end n
,(cast ( PATIENTS.SERIQ_NOMER_PASPORTA  as varchar (16) ) ) S_PASP
,(cast ( PATIENTS.SERIQ_NOMER_PASPORTA  as varchar (16) )) SN_PASP
,(cast ( 14 as varchar (2) ) ) Q_PASP,(cast ( null as datetime)) DAT_DUL,
 (cast (  PATIENTS.MODIFY_DATE_TIME  as datetime)) CHD
FROM
 FM_BILL FM_BILL 
LEFT OUTER JOIN PATIENTS PATIENTS ON PATIENTS.PATIENTS_ID = FM_BILL.PATIENTS_ID 
WHERE
 ((FM_BILL.BILL_DATE >= {ts '2012-01-31 00:00:00.000'} and FM_BILL.BILL_DATE - 1 < {ts '2012-01-31 00:00:00.000'}))
order by patient
