/*
������ � ����� ��� ������, ���� ������� ��������� � ������
*/
update old
set old.code=old.code+'old_2015'
,old.STATE='H'  /*���� ������*/
from FM_SERV old
join fm_serv new on new.code='new'+old.CODE

go

/*
������� new �� ���� ����� �����
*/
update fm_serv
set code=REPLACE(code,'new','')
from fm_serv
where code like 'new%'