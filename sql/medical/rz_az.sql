-- network protocol: TCP/IP
set quoted_identifier off
set arithabort off
set numeric_roundabort off
set ansi_warnings off
set ansi_padding off
set ansi_nulls off
set concat_null_yields_null off
set cursor_close_on_commit off
set implicit_transactions off
set language us_english
set dateformat mdy
set datefirst 7
set transaction isolation level read committed


/* TfStatPrm.ReportRequest 'RZ_AZ' */
SELECT 
FM_BILLDET.FM_BILL_ID
,FM_BILLDET.FM_BILLDET_ID
,FM_SERV.FM_SERV_ID
 ,FM_BILL.BILL_DATE, (cast((MEDECINS.NOM + ' ' + MEDECINS.PRENOM) AS VARCHAR(100))) m
 , FM_SERV.CODE, FM_SERV.LABEL, FM_SERV.CODE_AN, 
 FM_BILLDET.CNT, FM_BILLDET.PRICE_TO_PAY, 
 (Case
 /* коды услуг пустые */
when
isnull(US_MEDECINS_ZP.SERV_CODE_AN,'')='' and 
isnull( US_MEDECINS_ZP.EXCL_SERV_CODE_AN ,'')=''
then FM_BILLDET.PRICE_TO_PAY* US_MEDECINS_ZP.STAVKA 
/* заполнен включая, исключения пусто */
When len(US_MEDECINS_ZP.SERV_CODE_AN)>0 and  
isnull( US_MEDECINS_ZP.EXCL_SERV_CODE_AN ,'')='' and
 FM_SERV.CODE_AN in (select element from dbo.StrSplit( US_MEDECINS_ZP.SERV_CODE_AN ,','))
then FM_BILLDET.PRICE_TO_PAY* US_MEDECINS_ZP.STAVKA 
/* заполнены исключения */
when len( US_MEDECINS_ZP.EXCL_SERV_CODE_AN)>0 and
 isnull(FM_SERV.CODE_AN,'') not in (select element from dbo.StrSplit( US_MEDECINS_ZP.SERV_CODE_AN ,','))
then FM_BILLDET.PRICE_TO_PAY* US_MEDECINS_ZP.STAVKA 
end) z
 , US_MEDECINS_ZP.SERV_CODE_AN, US_MEDECINS_ZP.EXCL_SERV_CODE_AN, US_MEDECINS_ZP.STAVKA
 ----------------
FROM
 FM_BILL FM_BILL JOIN FM_BILLDET FM_BILLDET ON FM_BILL.FM_BILL_ID = FM_BILLDET.FM_BILL_ID 
 LEFT OUTER JOIN FM_SERV FM_SERV ON FM_SERV.FM_SERV_ID = FM_BILLDET.FM_SERV_ID 
 LEFT OUTER JOIN MEDECINS MEDECINS ON MEDECINS.MEDECINS_ID = FM_BILL.MEDECINS1_ID 
 LEFT OUTER JOIN US_MEDECINS_ZP US_MEDECINS_ZP ON (FM_BILL.MEDECINS1_ID= US_MEDECINS_ZP.MEDECINS_ID and ( 
 ( /* коды услуг пустые */ 
 isnull(US_MEDECINS_ZP.SERV_CODE_AN,'')='' and 
 isnull( US_MEDECINS_ZP.EXCL_SERV_CODE_AN ,'')='' 
 ) 
 or 
 (/* заполнен включая, исключения пусто */ 
 len(US_MEDECINS_ZP.SERV_CODE_AN)>0 and 
 isnull( US_MEDECINS_ZP.EXCL_SERV_CODE_AN ,'')='' and 
 FM_SERV.CODE_AN in (select element from dbo.StrSplit( US_MEDECINS_ZP.SERV_CODE_AN ,',')) 
 ) or 
 (/* заполнены исключения */ 
 len( US_MEDECINS_ZP.EXCL_SERV_CODE_AN)>0 and 
 isnull(FM_SERV.CODE_AN,'') not in (select element from dbo.StrSplit( US_MEDECINS_ZP.EXCL_SERV_CODE_AN ,',')) 
 ) 
 )
 )
WHERE
 (FM_BILLDET.CANCEL=0 and FM_BILLDET.BLOCKED=0 and FM_BILLDET.FM_SERV_ID<>17084
/*(select ltrim(rtrim(element)) from dbo.StrSplit('прием,опер,ман,смп,стац',','))*/)
 AND (FM_BILL.MEDECINS1_ID in (1910))
 AND ((FM_BILL.BILL_DATE = {ts '2017-03-20 00:00:00.000'}))
 and FM_SERV.FM_SERV_ID in(18008)
 order by CODE,FM_BILLDET.FM_BILLDET_ID
