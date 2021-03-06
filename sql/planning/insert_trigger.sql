/* Custom trigger */

Declare @USER_ID int
  ,@RT_ROLE_ID int
select @USER_ID = USER_ID, @RT_ROLE_ID=RT_USER.RT_ROLE_ID
from KRN_SYS_SESSIONS sess
join rt_user on rt_user.medecins_id=sess.USER_ID 
where SESSION_ID = @@SPID

if @USER_ID is not null 
and isnull(@RT_ROLE_ID,0) not in (1/*admin*/,34/*ginekol*/)
begin
	select @VALIDCNT = count(*) from inserted
	join PL_SUBJ on inserted.PL_SUBJ_ID = PL_SUBJ.PL_SUBJ_ID
	where datediff(d,getdate(),inserted.DATE_CONS)<8
	and isnull(inserted.status,0)=0    

	if @VALIDCNT<@NUMROWS
	begin
	select @ERRNO = 50001,
	  @ERRMSG = 'Cannot INSERT PLANNING Дата записи превышает допустимую. '
		+ CONVERT(VARCHAR(10), DATE_CONS, 104) +' '+cast(HEURE as varchar)
		from inserted	
	goto error
	end
end

no_custom:
/* --- End of custom trigger --- */
