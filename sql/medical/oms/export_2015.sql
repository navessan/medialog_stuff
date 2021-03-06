declare @period datetime
	,@fm_clink_id int

select @period = {ts '2015-05-01 00:00:00.000'}
	,@FM_CLINK_ID=3041

-----------------
truncate table us_oms_export_mu
-------------------

INSERT INTO [US_OMS_EXPORT_MU]
           ([PATIENT]
           ,[COD_U]
           ,[DS]
           ,[D_U]
           ,[P_U]
           ,[COD]
           ,[K_U]
           ,[ISHOD]
           ,[RSLT]
           ,[PROG]
           ,[CH_N]
           ,[DISP]
           ,[TRAVMA]
           ,[D_TYPE]
           ,[AP_ID]
           ,[C_I]
           ,[ND]
           ,[CHD]
           ,[obrachenie_kod]
           ,[MEDECINS_ID])
SELECT 
 (cast (  PATIENTS.PATIENTS_ID  as varchar (36) ) ) PATIENT
,(cast (   MEDECINS.KOD1+'-'+
   case when isnull(OMS_MAIN_CODE,'')<>''   then OMS_MAIN_CODE
   else FM_DEP.CODE   end as varchar (36) ) ) COD_U
,(cast ( case when CIM10.CODE like 'k64%' then 'I84'+substring(CIM10.CODE,4,2)
 else CIM10.CODE end as varchar (6) ) ) DS
,(cast ( FM_BILL.BILL_DATE  as datetime)) D_U
,(cast ( max(1) as varchar (1) ) ) P_U
,(cast ( US_OMS_TO_OBLAST.oblast as varchar (15) ) ) COD
,(cast ( sum( CEILING(FM_BILLDET.CNT / coalesce( US_OMS_TO_OBLAST.DELITEL,1))  ) as numeric (6,2) ) ) K_U,
 (cast ( max('') as varchar (3) ) ) ISHOD
,(cast ( max('') as varchar (3) ) ) RSLT
,(cast ( case
              when PATIENTS.MO_I_REGION =1 then  'ОМСМО'
             when PATIENTS.OMS_GITELI_ROSSII =1 then 'ДРУГОЕ'
             when PATIENTS.MOSKVA=1 then  'ОМСМК'
             else 'ДРУГОЕ' end as varchar (10) ) ) PROG
,(cast ( max('') as varchar (1) ) ) CH_N
,(cast ( max('') as varchar (1) ) ) DISP
,(cast ( max('') as varchar (2) ) ) TRAVMA
,(cast ( max('') as varchar (3) ) ) D_TYPE
,(cast ( max('') as varchar (36) ) ) AP_ID
,(cast ( max('') as varchar (30) ) ) C_I
,(cast ( max(0) as numeric (9,0) ) ) ND
,(cast ( max(FM_BILL.KRN_MODIFY_DATE) as datetime)) CHD
,US_OMS_TO_OBLAST.oblast_obrachenie
,FM_BILL.MEDECINS1_ID
FROM
 FM_BILL FM_BILL WITH(NOLOCK)  LEFT OUTER JOIN PATIENTS PATIENTS WITH(NOLOCK)  ON PATIENTS.PATIENTS_ID = FM_BILL.PATIENTS_ID 
 LEFT OUTER JOIN OMS_SMO OMS_SMO WITH(NOLOCK)  ON OMS_SMO.OMS_SMO_ID = PATIENTS.SMO 
 LEFT OUTER JOIN OMS_SMO OMS_SMO_1 WITH(NOLOCK)  ON OMS_SMO_1.OMS_SMO_ID = PATIENTS.SMO_REGION 
 LEFT OUTER JOIN OMS_SERPOL OMS_SERPOL WITH(NOLOCK)  ON (PATIENTS.SERIQ_SPR =OMS_SERPOL.OMS_SERPOL_ID)
 LEFT OUTER JOIN OMS_OBLAST OMS_OBLAST WITH(NOLOCK)  ON OMS_OBLAST.OMS_OBLAST_ID = PATIENTS.KOD_TERRITORII 
 JOIN FM_BILLDET FM_BILLDET WITH(NOLOCK)  ON FM_BILL.FM_BILL_ID = FM_BILLDET.FM_BILL_ID 
 LEFT OUTER JOIN FM_CLINK FM_CLINK WITH(NOLOCK)  ON FM_CLINK.FM_CLINK_ID = FM_BILLDET.FM_CLINK_ID 
 JOIN FM_SERV FM_SERV WITH(NOLOCK)  ON FM_SERV.FM_SERV_ID = FM_BILLDET.FM_SERV_ID 
 LEFT OUTER JOIN US_DMS_TO_OMS US_DMS_TO_OMS WITH(NOLOCK)  ON (FM_SERV.CODE= US_DMS_TO_OMS.dms_code)
 JOIN US_OMS_TO_OBLAST US_OMS_TO_OBLAST WITH(NOLOCK)  ON 
	((FM_CLINK.FM_CLINK_ID in (@FM_CLINK_ID)
	 and US_DMS_TO_OMS.oms_code= US_OMS_TO_OBLAST.moscow) or FM_SERV.CODE='о'+US_OMS_TO_OBLAST.moscow)
 LEFT OUTER JOIN CIM10 CIM10 WITH(NOLOCK)  ON CIM10.CIM10_ID = FM_BILL.CIM10_ID 
 LEFT OUTER JOIN MEDECINS MEDECINS WITH(NOLOCK)  ON MEDECINS.MEDECINS_ID = FM_BILL.MEDECINS1_ID 
 JOIN MEDECINS_INFO MEDECINS_INFO WITH(NOLOCK)  ON MEDECINS.MEDECINS_ID = MEDECINS_INFO.MEDECINS_ID 
 LEFT OUTER JOIN MEDECINS MEDECINS2 WITH(NOLOCK)  ON MEDECINS2.MEDECINS_ID = FM_BILL.MEDECINS2_ID 
 LEFT OUTER JOIN FM_DEP FM_DEP WITH(NOLOCK)  ON FM_DEP.FM_DEP_ID = FM_BILL.FM_DEP_ID 
 JOIN US_OMS_DEP_LINK US_OMS_DEP_LINK WITH(NOLOCK)  ON FM_DEP.FM_DEP_ID = US_OMS_DEP_LINK.FM_DEP_ID 
WHERE
   FM_BILL.BILL_DATE>= DATEADD(month, DATEDIFF(month, 0, @period), 0)  
and FM_BILL.BILL_DATE< DATEADD(month, DATEDIFF(month, 0, @period)+1, 0)  
and US_OMS_DEP_LINK.PROFILE_cl1850 is not null 
and (FM_CLINK.FM_CLINK_ID in(2045,4761) 
		or (  FM_CLINK.FM_CLINK_ID in (@FM_CLINK_ID) and isnull(US_DMS_TO_OMS.oms_code,'')<>'') 
	)   
AND not FM_BILL.FM_DEP_ID in (17)
AND PATIENTS.MO_I_REGION=1
GROUP BY
 (cast (  PATIENTS.PATIENTS_ID  as varchar (36) ) )
,(cast (  MEDECINS.KOD1+'-'+   case when isnull(OMS_MAIN_CODE,'')<>''   then OMS_MAIN_CODE   else FM_DEP.CODE   end as varchar (36) ) )
,(cast ( case when CIM10.CODE like 'k64%' then 'I84'+substring(CIM10.CODE,4,2) else CIM10.CODE end as varchar (6) ) )
,(cast (  FM_BILL.BILL_DATE  as datetime))
,(cast (  US_OMS_TO_OBLAST.oblast as varchar (15) ) ),
 (cast ( case
             when PATIENTS.MO_I_REGION =1 then  'ОМСМО'
             when PATIENTS.OMS_GITELI_ROSSII =1 then 'ДРУГОЕ'
             when PATIENTS.MOSKVA=1 then  'ОМСМК'
             else 'ДРУГОЕ' end as varchar (10) ) )
,US_OMS_TO_OBLAST.oblast_obrachenie
,FM_BILL.MEDECINS1_ID

/*
MOTCONSU.PATIENTS_ID= FM_BILL.PATIENTS_ID and 
MOTCONSU.MEDECINS_ID= FM_BILL.MEDECINS1_ID and
dateadd(day,0,DATEDIFF(day, 0, MOTCONSU.DATE_CONSULTATION))= FM_BILL.BILL_DATE
*/
--------------------------

update us_oms_export_mu
	set obr_cnt=
(select count(ds) from us_oms_export_mu sub 
where
	sub.PATIENT=mu.PATIENT 
and sub.obrachenie_kod=mu.obrachenie_kod 
and sub.ds=mu.ds 
--and sub.d_u<>mu.d_u
)
from us_oms_export_mu mu
where len(obrachenie_kod)>0

--------------------------
update mu set
	RSLT='3'
	,event_closed=1
from us_oms_export_mu mu
where len(obrachenie_kod)>0
and obr_cnt>1
and not exists(
select top 1 ds from us_oms_export_mu sub 
where
	sub.PATIENT=mu.PATIENT 
and sub.obrachenie_kod=mu.obrachenie_kod 
and sub.ds=mu.ds 
and sub.d_u>mu.d_u
order by d_u
)
--------------------------

/*
select [PATIENT]
           ,[COD_U]
           ,[DS]
           ,[D_U]
           ,[P_U]
           ,[COD]
           ,[K_U]
           ,[ISHOD]
           ,[RSLT]
           ,[PROG]
           ,[CH_N]
           ,[DISP]
           ,[TRAVMA]
           ,[D_TYPE]
           ,[AP_ID]
           ,[C_I]
           ,[ND]
           ,[CHD]
           ,[obrachenie_kod]
--           ,mu.[MEDECINS_ID]
,*
from us_oms_export_mu mu
*/
/*join motconsu on
MOTCONSU.PATIENTS_ID= mu.PATIENT and 
MOTCONSU.MEDECINS_ID= mu.MEDECINS_ID and
dateadd(day,0,DATEDIFF(day, 0, MOTCONSU.DATE_CONSULTATION))= D_U
*/