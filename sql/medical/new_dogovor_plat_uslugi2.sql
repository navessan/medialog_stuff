declare @P1 int
declare @P2 int
declare @patients_id int
declare @date_from as datetime    
declare @date_to as datetime
declare @orgs as varchar(32)   
		,@new_police varchar(32) 
declare @fm_org_id int          
declare @user_id int          
declare @date_create as datetime
declare @fm_clink_id int 

declare @info_id int
		,@dog_num varchar(32)


set nocount on

set @patients_id=160918	--test
--set @patients_id=:%AF_CURRENT_PATIENT  

set @orgs='05'
set @fm_org_id=3
set @user_id=1	--admin
--set @user_id=:%AF_CURRENT_MEDECIN  
set @fm_clink_id=3795	--id платного договора

/*
1) Если нет записей в доп таблице, то нужно создать запись.
*/

select 
@dog_num=isnull(nomer_platnogo_dogovora,'')
,@info_id=data126_id
from data126 where patients_id=@patients_id

if(@info_id is not null)
begin
	select 'dopinfo data126 record exists, dog number='+@dog_num
end
else
begin
	select 'no dopinfo data126 record'
	exec up_get_id  @KeyName = 'DATA126', @Shift = 1, @ID = @P1 output
	insert into DATA126 (DATA126_ID,patients_id) values (@P1,@patients_id)
end

/*
 текущее прикрепление, если не заполнена дата окончания и полис, то закрыть.
*/

	update FM_CLINK_PATIENTS
	set date_cancel=DATEADD(day, DATEDIFF(day, 0, getdate()), 0)
		,CANCEL=1
	where 
		patients_id=@patients_id
		and fm_clink_id=@fm_clink_id 
		and (date_cancel is null or date_cancel> getdate())
		and (date_to is null or date_to> getdate())
		and isnull(police,'')=''

/*
проверить date_to
если дата меньше, то нужен новый номер договора
*/
	select FM_CLINK_PATIENTS_ID,fm_clink_id,date_to,police
	from  FM_CLINK_PATIENTS
	where 
		patients_id=@patients_id
		and fm_clink_id=@fm_clink_id 
		and (date_cancel is null or date_cancel> getdate())
		and (date_to is null or date_to> getdate())

if not exists 
	(
	select fm_clink_id
	from  FM_CLINK_PATIENTS
	where 
		patients_id=@patients_id
		and fm_clink_id=@fm_clink_id 
		and (date_cancel is null or date_cancel> getdate())
		and (date_to is null or date_to> getdate())
	)
BEGIN
/*
нужно создать новый номер договора и новое прикрепление с датами.
*/
	declare @Value integer, @Template varchar(50)

	exec dbo.up_get_counter_value  @KeyName = 'pu_dog_num',  @Shift = 1,
		@Value = @Value output, @Template = @Template output

	set @dog_num= convert(varchar(4),datepart(yyyy,getdate()))+'-'+convert(varchar(16),@Value)

	update DATA126 set 
		MODIFY_DATE_TIME=getdate()
		,NOMER_PLATNOGO_DOGOVORA=@dog_num
	where patients_id=@patients_id

	select 'NEW dog number='+@dog_num

select @date_from=DATEADD(day, DATEDIFF(day, 0, getdate()), 0)
	,@date_to=DATEADD(year,1,@date_from)
	,@date_create=getdate()
	,@new_police=@dog_num

select @date_from from_ ,@date_to to_ ,@new_police

exec up_get_id  @KeyName = 'FM_CLINK_PATIENTS', @Shift = 1, @ID = @P1 output
exec up_get_id  @KeyName = 'FM_CLINK_PATIENTS_ORG', @Shift = 1, @ID = @P2 output
select @P1 FM_CLINK_PATIENTS_ID, @P2 FM_CLINK_PATIENTS_ORG_ID

	insert into FM_CLINK_PATIENTS
	(FM_CLINK_PATIENTS_ID,PATIENTS_ID,FM_CLINK_ID
	,DATE_FROM,DATE_TO,POLICE
	,MEDECINS_ID,CANCEL,MEDECINS_CREATE_ID,DATE_CREATE,
	ORGS,FORCED_ORGS,FORCED_EXTORGS,CHANGED,DEF_CP)
	values(@P1,@patients_id,@fm_clink_id
	,@date_from,@date_to,@new_police
	,@user_id,0,@user_id,@date_create,@orgs,0,0,1,0)

	insert into FM_CLINK_PATIENTS_ORG
	(FM_CLINK_PATIENTS_ORG_ID,FM_CLINK_PATIENTS_ID,FM_ORG_ID,KRN_CREATE_USER_ID,KRN_MODIFY_USER_ID)
	values(@P2,@P1,@fm_org_id,@user_id,@user_id)

END;