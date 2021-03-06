/*������� �����-���� ��� ���� ������� ��� ����� ��� �� �������
 ������� ����� �������������
*/
declare @barcode_prefix varchar(32)
set @barcode_prefix = 'PTDR'

/* �����-��� ������ ����������� */
declare @PATDIREC_barcode varchar(32)
set @PATDIREC_barcode = 'PTDR658469'

/* �������� ��������, ������ ����� */
select @PATDIREC_barcode=(
CASE
 WHEN replace(@PATDIREC_barcode, @barcode_prefix, '') not LIKE '%[^0-9]%'
 THEN replace(@PATDIREC_barcode, @barcode_prefix, '')
 ELSE '0' END)

--------------------------------
declare @PATDIREC_ID int
set @PATDIREC_ID = convert(int,@PATDIREC_barcode)

/* ��������� ����������� */
SELECT 
 PATDIREC.PATDIREC_ID,PATDIREC.PATIENTS_ID,PATDIREC.MOTCONSU_ID
,PATDIREC.PL_EXAM_ID,PL_EXAM.CODE,PL_EXAM.NAME
,(MEDECINS_1.NOM + ' ' + MEDECINS_1.PRENOM) Med1
,FM_DEP.CODE,FM_DEP.LABEL
,CIM10.CODE CODE_1,CIM10.DESCRIPTION
FROM
 PATDIREC PATDIREC
 JOIN PL_EXAM PL_EXAM ON PL_EXAM.PL_EXAM_ID = PATDIREC.PL_EXAM_ID 
 LEFT OUTER JOIN MOTCONSU MOTCONSU ON MOTCONSU.MOTCONSU_ID = PATDIREC.MOTCONSU_ID
 LEFT OUTER JOIN FM_BILL ON MOTCONSU.MOTCONSU_ID = FM_BILL.MOTCONSU_ID
 LEFT OUTER JOIN MEDECINS MEDECINS_1 ON MEDECINS_1.MEDECINS_ID = coalesce(FM_BILL.MEDECINS1_ID,MOTCONSU.MEDECINS_ID)
 LEFT OUTER JOIN MEDECINS MEDECINS_2 ON MEDECINS_2.MEDECINS_ID = FM_BILL.MEDECINS2_ID
 LEFT OUTER JOIN FM_DEP FM_DEP ON FM_DEP.FM_DEP_ID = coalesce(FM_BILL.FM_DEP_ID,MOTCONSU.FM_DEP_ID) 
 LEFT OUTER JOIN DATA22 DIAGNOZY ON MOTCONSU.MOTCONSU_ID = DIAGNOZY.MOTCONSU_ID and isnull(DIAGNOZY.N_LINE,1)=1
 LEFT OUTER JOIN CIM10 CIM10 ON CIM10.CIM10_ID = coalesce(FM_BILL.CIM10_ID,DIAGNOZY.DIAGNOZ_V_NAPRAVLENIE,10686) /* z00.0 default */
WHERE
PATDIREC.PATDIREC_ID=@PATDIREC_ID

/* ��������� ��������
*/
SELECT 
 PATDIREC.PATDIREC_ID,PATDIREC.PATIENTS_ID
,NOM, PRENOM, PATRONYME, NE_LE, POL, MEDICINSKAQ_KARTA 
,FM_CLINK.CODE
,FM_CONTR.CODE
,FM_CLINK.FM_CLINK_ID
FROM
 PATDIREC PATDIREC
 JOIN PATIENTS ON PATDIREC.PATIENTS_ID=PATIENTS.PATIENTS_ID 

LEFT OUTER JOIN FM_CLINK_PATIENTS FM_CLINK_PATIENTS ON ((FM_CLINK_PATIENTS.PATIENTS_ID = PATIENTS.PATIENTS_ID) and (FM_CLINK_PATIENTS.DATE_FROM) <= GETDATE() and ((FM_CLINK_PATIENTS.DATE_TO) >= GETDATE() or FM_CLINK_PATIENTS.DATE_TO is null) and (FM_CLINK_PATIENTS.DATE_CANCEL is null or (FM_CLINK_PATIENTS.DATE_CANCEL) > GETDATE()))

 LEFT OUTER JOIN FM_CLINK FM_CLINK ON FM_CLINK.FM_CLINK_ID = FM_CLINK_PATIENTS.FM_CLINK_ID 
 LEFT OUTER JOIN FM_CONTR FM_CONTR ON FM_CONTR.FM_CONTR_ID = FM_CLINK.FM_CONTR_ID
WHERE
PATDIREC.PATDIREC_ID=@PATDIREC_ID

/* ���������� ������ ����������� 
������������ ����� ����� ���� ������� �� ����� ������������ 
������ ���� ������� ���������� ������
*/

SELECT DIR_SERV.*
,FM_SERV.FM_SERV_ID,FM_SERV.CODE,FM_SERV.LABEL
FROM DIR_SERV DIR_SERV 
LEFT OUTER JOIN FM_SERV FM_SERV ON FM_SERV.FM_SERV_ID=DIR_SERV.FM_SERV_ID 
WHERE DIR_SERV.PATDIREC_ID = @PATDIREC_ID
