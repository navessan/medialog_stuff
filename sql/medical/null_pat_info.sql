UPDATE PATIENTS
set NOM='������',
    PRENOM='����',
    PATRONYME='��������',
    FIO='������ �.�.',
    NE_LE='1972/03/12',
    FAKTIHESKIJ_ADRES='127055, �. ������, ��. ��������������, �.73, ���. 1, 5-� ����',
    ADRES_PO_MESTU_GITEL_STVA='127055, �. ������, ��. ��������������, �.73, ���. 1, 5-� ����',
    ADRES='127055, �. ������, ��. ��������������, �.73, ���. 1, 5-� ����',
    RAB_TEL='780-6051',
    TEL='780-6051',
    TEL_MOB='780-6051',
    FAKS='780-6051',
    ULICA='780-6051',
    GOROD='������',
    DOM='73',
    KVARTIRA='5'
UPDATE FM_PATIENTS
set NOM='������',
    PRENOM='����',
    PATRONYME='��������',
    POLICE=convert(char,( RAND(FM_PATIENTS_id)*10000000000 ),2 )
UPDATE PLANNING
set NOM='������',
    PRENOM='����',
    PATRONYME='��������'
UPDATE CALLS
set PAT_NOM='������',
    PAT_PRENOM='����',
    PAT_PATRONYME='��������'
UPDATE FM_CLINK_PATIENTS
set POLICE=convert(char,( RAND(FM_CLINK_PATIENTS_id)*10000000000 ),2 )
UPDATE HO_RESDET
set NOM='������',
    PRENOM='����',
    PATRONYME='��������'


