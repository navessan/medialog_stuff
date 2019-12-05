declare @D varchar(16)

set @D=getdate();
set @D= right('0' + rtrim(day(@D)),2) + '.' 
		+ right('0' + rtrim(month(@D)),2) + '.' 
		+ right(rtrim(year(@D)),4);

update us_oms_export_dd set dd_val=@D where dd_tag='XPRT_DATE'

set @D={ts '2012-01-01 00:00:00.000'}
if (@d is not null) 
begin
	set @D= right('0' + rtrim(day(@D)),2) + '.' 
			+ right('0' + rtrim(month(@D)),2) + '.' 
			+ right(rtrim(year(@D)),4);
	update us_oms_export_dd set dd_val=@D where dd_tag='REPP_BEGD'
end

set @D={ts '2012-01-31 00:00:00.000'}
if (@D is not null)
begin
	set @D= right('0' + rtrim(day(@D)),2) + '.' 
			+ right('0' + rtrim(month(@D)),2) + '.' 
			+ right(rtrim(year(@D)),4);
	update us_oms_export_dd set dd_val=@D where dd_tag='REPP_ENDD'
end

select * from us_oms_export_dd