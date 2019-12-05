declare @d datetime

select @d=getdate();
select right('0' + rtrim(day(@d)),2) + '.' + right('0' + rtrim(month(@d)),2) + '.' + right(rtrim(year(@d)),2)



select convert(varchar(4),datepart(yyyy,@d))+'.'
		+convert(varchar(4),datepart(mm,@d))+'.'
		+convert(varchar(4),datepart(dd,@d))



SELECT DATEADD(day, DATEDIFF(day, 0, getdate()), 0) 