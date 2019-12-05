UPDATE PATIENTS
set NOM='ИВАНОВ',
    PRENOM='Иван',
    PATRONYME='Иванович',
    FIO='Иванов И.И.',
    NE_LE='1972/03/12',
    FAKTIHESKIJ_ADRES='127055, г. Москва, ул. Новослободская, д.73, стр. 1, 5-й этаж',
    ADRES_PO_MESTU_GITEL_STVA='127055, г. Москва, ул. Новослободская, д.73, стр. 1, 5-й этаж',
    ADRES='127055, г. Москва, ул. Новослободская, д.73, стр. 1, 5-й этаж',
    RAB_TEL='780-6051',
    TEL='780-6051',
    TEL_MOB='780-6051',
    FAKS='780-6051',
    ULICA='780-6051',
    GOROD='Москва',
    DOM='73',
    KVARTIRA='5'
UPDATE FM_PATIENTS
set NOM='ИВАНОВ',
    PRENOM='Иван',
    PATRONYME='Иванович',
    POLICE=convert(char,( RAND(FM_PATIENTS_id)*10000000000 ),2 )
UPDATE PLANNING
set NOM='ИВАНОВ',
    PRENOM='Иван',
    PATRONYME='Иванович'
UPDATE CALLS
set PAT_NOM='ИВАНОВ',
    PAT_PRENOM='Иван',
    PAT_PATRONYME='Иванович'
UPDATE FM_CLINK_PATIENTS
set POLICE=convert(char,( RAND(FM_CLINK_PATIENTS_id)*10000000000 ),2 )
UPDATE HO_RESDET
set NOM='ИВАНОВ',
    PRENOM='Иван',
    PATRONYME='Иванович'


