/*
кидаем в архив все услуги, коды которых совпадают с новыми
*/
update old
set old.code=old.code+'old_2015'
,old.STATE='H'  /*флаг архива*/
from FM_SERV old
join fm_serv new on new.code='new'+old.CODE

go

/*
убираем new из кода новых услуг
*/
update fm_serv
set code=REPLACE(code,'new','')
from fm_serv
where code like 'new%'