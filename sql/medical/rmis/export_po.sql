/* TfStatPrm.ReportRequest 'oms_export_po' */
SELECT DISTINCT 
 (cast (  PATIENTS.PATIENTS_ID  as varchar (36) ) ) PATIENT,
 (cast ( case 
when PATIENTS.MO_I_REGION =1 
then  Substring (PATIENTS.SERIQ_NOMER_POLISA_OMS , 1, CharIndex (' ', PATIENTS.SERIQ_NOMER_POLISA_OMS+' ', 0)-1)              
when PATIENTS.OMS_GITELI_ROSSII =1 
then Substring (PATIENTS.SERIQ_NOMER_POLISA_OMS_RE  , 1, CharIndex (' ', PATIENTS.SERIQ_NOMER_POLISA_OMS_RE +' ', 0)-1)             when PATIENTS.MOSKVA=1 
then OMS_SERPOL.COD             
else null end  as varchar (16) ) ) S_POL
,(cast (  
case  when PATIENTS.MO_I_REGION =1  
then Substring( Substring(PATIENTS.SERIQ_NOMER_POLISA_OMS, CharIndex(' ', PATIENTS.SERIQ_NOMER_POLISA_OMS +' ',0)+1,100)
, 1, CharIndex(' ', Substring(PATIENTS.SERIQ_NOMER_POLISA_OMS, CharIndex(' ', PATIENTS.SERIQ_NOMER_POLISA_OMS +' ',0)+1,100)+' ',0)-1)  
when PATIENTS.OMS_GITELI_ROSSII =1 
then  Substring( Substring(PATIENTS.SERIQ_NOMER_POLISA_OMS_RE , CharIndex(' ', PATIENTS.SERIQ_NOMER_POLISA_OMS_RE +' ',0)+1,100), 1, CharIndex(' ', Substring(PATIENTS.SERIQ_NOMER_POLISA_OMS_RE , CharIndex(' ', PATIENTS.SERIQ_NOMER_POLISA_OMS_RE  +' ',0)+1, 100)+' ',0)-1)  
when PATIENTS.MOSKVA=1 
then PATIENTS.NOMER_KMS else null end  as varchar (16) )) SN_POL

 ,(cast (  OMS_OBLAST.OBLAST_CODE  as varchar (2) ) ) C_T
,(cast ( case              
when PATIENTS.MO_I_REGION =1 then  OMS_SMO_1.SMO_OGRN              
when PATIENTS.OMS_GITELI_ROSSII =1 then OMS_SMO_1.SMO_OGRN              
when PATIENTS.MOSKVA=1 then  OMS_SMO.SMO_OGRN             
else null end as varchar (15) ) ) Q_OGRN

,(cast ( 1 as varchar (1) ) ) T_POL

,(cast ( case              
when PATIENTS.MOSKVA=1 
then isnull((select top 1 s_name from us_oms_cl0700 where s_regn='77' and s_ogrn=OMS_SMO.SMO_OGRN),OMS_SMO.smo_name)    
when PATIENTS.MO_I_REGION =1 
then isnull((select top 1 s_name from us_oms_cl0700 where s_regn='50' and s_ogrn=OMS_SMO_1.SMO_OGRN),OMS_SMO_1.smo_name )
when PATIENTS.OMS_GITELI_ROSSII =1 
then isnull((select top 1 s_name from us_oms_cl0700 where s_regn=OMS_OBLAST.OBLAST_CODE  and s_ogrn=OMS_SMO_1.SMO_OGRN), OMS_SMO_1.smo_name)
else null end as varchar (254) )) QD_NAME
 
,(cast ( null as datetime)) DATE_N
,(cast ( null as datetime)) DATE_E
,(cast ( 1 as varchar (1) ) ) POL_S

,(cast (case 
when PATIENTS.MO_I_REGION =1 then  'region'              
when PATIENTS.OMS_GITELI_ROSSII =1 then 'rosii'
when PATIENTS.MOSKVA=1 then  'moskva'
else null end as varchar (15) )) flag

,OMS_SMO.smo_name 
,OMS_SMO_1.smo_name region_name
FROM
 FM_BILL FM_BILL 
 LEFT OUTER JOIN PATIENTS PATIENTS ON PATIENTS.PATIENTS_ID = FM_BILL.PATIENTS_ID 
 LEFT OUTER JOIN OMS_SMO OMS_SMO ON OMS_SMO.OMS_SMO_ID = PATIENTS.SMO 
 LEFT OUTER JOIN OMS_SMO OMS_SMO_1 ON OMS_SMO_1.OMS_SMO_ID = PATIENTS.SMO_REGION 
 LEFT OUTER JOIN OMS_SERPOL OMS_SERPOL ON (PATIENTS.SERIQ_SPR =OMS_SERPOL.OMS_SERPOL_ID)
 LEFT OUTER JOIN OMS_OBLAST OMS_OBLAST ON OMS_OBLAST.OMS_OBLAST_ID = PATIENTS.KOD_TERRITORII 
WHERE
 ((PATIENTS.PLATN_J =0 AND PATIENTS.DMS =0 AND PATIENTS.MEDICINSKAQ_KARTA IS NOT NULL))
 AND ((FM_BILL.BILL_DATE >= {ts '2012-01-01 00:00:00.000'} 
and FM_BILL.BILL_DATE - 1 < {ts '2012-01-31 00:00:00.000'}))
