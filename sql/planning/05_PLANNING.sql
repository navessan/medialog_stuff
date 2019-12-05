SELECT 
 PLANNING.PLANNING_ID,PLANNING.PL_SUBJ_ID,PLANNING.DATE_CONS,PLANNING.HEURE,PLANNING.DUREE,
 PLANNING.PATIENTS_ID,PLANNING.NOM,PLANNING.PRENOM,PLANNING.MOTIF,PLANNING.COMMENTAIRE,
 PLANNING.COLOR,PLANNING.FONT,PLANNING.DUREE_TEXT,PLANNING.PATIENT_ARRIVEE,PLANNING.PL_GENER_ID,
 PLANNING.PL_EXAM_ID,PLANNING.PATRONYME,PLANNING.MEDECINS_CREATOR_ID,PLANNING.MODIFY_DATE_TIME,PLANNING.FM_PATIENTSTYPE_ID,
 PLANNING.CREATE_DATE_TIME,PLANNING.MEDECINS_MODIFY_ID,PLANNING.COULEUR_MACRO,PATDIREC.PATDIREC_ID,DIR_ANSW.FM_BILL_ID,
 convert(varchar(50),null) HEURE_TEXT,convert(varchar(100),null) MED_NAME,PL_EXAM.MODELS_ID,PLANNING.CALLS_ID,PLANNING.HL7_ACCESSION_NUMBER,
 PLANNING.CANCELLED,PLANNING.DIR_ANSW_LINKED,PLANNING.STATUS,convert(bit, 0) IS_EXPECTED,PATIENTS.N_OMON,
 PLANNING.ARRIVE_DATE,PATIENTS.MEDICINSKAQ_KARTA
FROM
 PLANNING PLANNING LEFT OUTER JOIN PATDIREC PATDIREC ON PLANNING.PLANNING_ID = PATDIREC.PLANNING_ID 
 LEFT OUTER JOIN DIR_ANSW DIR_ANSW ON PATDIREC.PATDIREC_ID = DIR_ANSW.PATDIREC_ID 
 LEFT OUTER JOIN PL_EXAM PL_EXAM ON PL_EXAM.PL_EXAM_ID = PLANNING.PL_EXAM_ID 
 LEFT OUTER JOIN PATIENTS PATIENTS ON PATIENTS.PATIENTS_ID = PLANNING.PATIENTS_ID 
WHERE
 (PLANNING.PL_SUBJ_ID=326)
 AND (PLANNING.DATE_CONS>='20110404 00:00:00.000' AND PLANNING.DATE_CONS<='20110410 00:00:00.000')
 AND (isnull(PLANNING.STATUS, 0) = 0)