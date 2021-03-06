declare @ID_P1 int
declare @ID_P2 int
declare @patients_id int
declare @date_from as datetime    
declare @date_to as datetime
declare @orgs as varchar(32)   
		,@new_police varchar(32) 
declare @fm_org_id int          
declare @user_id int          
declare @date_create as datetime
declare @fm_clink_id int 
	,@PL_fm_clink_id int

declare @info_id int
		,@dog_num varchar(32)
		,@dog_type varchar(32)

set nocount on

set @PL_fm_clink_id=3795	--id платного договора



--set @patients_id=160918	--test
set @patients_id=160918  

set @orgs='05'
set @fm_org_id=3
--set @user_id=1	--admin
set @user_id=920  

select @fm_clink_id=30453	--id скидка ФТО
	,@date_from='20150101 00:00:00.000'

DECLARE cur CURSOR FOR
------------
select
patients_id
	from  FM_CLINK_PATIENTS
	join FM_CLINK on (fm_clink.fm_clink_id=FM_CLINK_PATIENTS.fm_clink_id and FM_CLINK.FM_CONTR_ID in (415/*RESO*/, 12961/*investstrah*/))
	where 
		(FM_CLINK_PATIENTS.date_cancel is null or FM_CLINK_PATIENTS.date_cancel> getdate())
		and (FM_CLINK_PATIENTS.date_to is null or FM_CLINK_PATIENTS.date_to> getdate())
and patients_id in
(
select patients_id
	from  FM_CLINK_PATIENTS sub
	where 
		sub.fm_clink_id=@PL_fm_clink_id
		and (date_cancel is null or date_cancel> getdate())
		and (date_to is null or date_to> getdate())

)
------------

OPEN Cur;
FETCH NEXT FROM Cur into @patients_id;
WHILE @@FETCH_STATUS = 0
begin /* start cursor action*/

/* прикрепление скидки ФТО для страховых */
select @date_to=null

select top 1 @date_to=FM_CLINK_PATIENTS.date_to
	from  FM_CLINK_PATIENTS
	join FM_CLINK on fm_clink.fm_clink_id=FM_CLINK_PATIENTS.fm_clink_id
	where 
		patients_id=@patients_id
		and FM_CLINK.FM_CONTR_ID in (415/*RESO*/, 12961/*investstrah*/)
		and (FM_CLINK_PATIENTS.date_cancel is null or FM_CLINK_PATIENTS.date_cancel> getdate())
		and (FM_CLINK_PATIENTS.date_to is null or FM_CLINK_PATIENTS.date_to> getdate())

select @patients_id patients_id, 'skidka strahovyh do', @date_from date_from, @date_to date_to

if @date_to>getdate()
and not exists 
	(
	select fm_clink_id
	from  FM_CLINK_PATIENTS
	where 
		patients_id=@patients_id
		and fm_clink_id=@fm_clink_id 
		and (date_cancel is null or date_cancel> getdate())
		and (date_to is null or date_to> getdate())
	)

begin
	select 'skidki FTO net'
	select /*@date_from=DATEADD(day, DATEDIFF(day, 0, getdate()), 0)
		,@date_to=date_to
		,*/@date_create=getdate()
		,@new_police=police
	from  FM_CLINK_PATIENTS
	where 
		patients_id=@patients_id
		and fm_clink_id=@PL_fm_clink_id 
		and (date_cancel is null or date_cancel> getdate())
		and (date_to is null or date_to> getdate())

	exec up_get_id  @KeyName = 'FM_CLINK_PATIENTS', @Shift = 1, @ID = @ID_P1 output
	exec up_get_id  @KeyName = 'FM_CLINK_PATIENTS_ORG', @Shift = 1, @ID = @ID_P2 output
	select @ID_P1 FM_CLINK_PATIENTS_ID, @ID_P2 FM_CLINK_PATIENTS_ORG_ID

	insert into FM_CLINK_PATIENTS
	(FM_CLINK_PATIENTS_ID,PATIENTS_ID,FM_CLINK_ID
	,DATE_FROM,DATE_TO,POLICE
	,MEDECINS_ID,CANCEL,MEDECINS_CREATE_ID,DATE_CREATE,
	ORGS,FORCED_ORGS,FORCED_EXTORGS,CHANGED,DEF_CP)
	values(@ID_P1,@patients_id,@fm_clink_id
	,@date_from,@date_to,@new_police
	,@user_id,0,@user_id,@date_create,@orgs,0,0,1,0)

	insert into FM_CLINK_PATIENTS_ORG
	(FM_CLINK_PATIENTS_ORG_ID,FM_CLINK_PATIENTS_ID,FM_ORG_ID,KRN_CREATE_USER_ID,KRN_MODIFY_USER_ID)
	values(@ID_P2,@ID_P1,@fm_org_id,@user_id,@user_id)

end

FETCH NEXT FROM Cur into @patients_id;
end /* end cursor action*/

CLOSE Cur;
DEALLOCATE Cur;