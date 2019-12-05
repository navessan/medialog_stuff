
set nocount on

declare 
	@DateFrom DateTime
	,@DateTo DateTime
	,@D datetime
	,@LastMonth int

select 
	@D=GETDATE()
	,@LastMonth=0


SELECT DATEADD(month, DATEDIFF(month, 0, @D), 0) AS StartOfMonth
		,DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, @D) + 1, 0))	as EndOfMonth

SELECT @DateFrom=DATEADD(month, DATEDIFF(month, 0, @D)-@LastMonth, 0)
	,@DateTo=DATEADD(d, -1, DATEADD(m, DATEDIFF(MONTH, 0, @D)+1-@LastMonth, 0))

declare @tbl table(d datetime,dep varchar(512),name varchar(512),start_time datetime,start_place varchar(512),end_time datetime,end_place varchar(512),work datetime)
--convert(varchar(20),L_start.DateTime,108) as start_time

select @D = @DateFrom	

select @D, @DateTo

while @D <= @DateTo
begin
------
insert into @tbl
SELECT distinct
@D as datet,
EmployeeGroup.Name as dep
,isnull([LastName],'')+' '+isnull([FirstName],'') +' '+isnull([SecondName],'') as name
--,L_start.Message
,L_start.DateTime as start_time
,prop_st.Value as start_place
--,L_end.[Message]
,L_end.DateTime as end_time
,prop_end.Value as end_place
,cast(L_end.DateTime as datetime)- cast(L_start.DateTime as datetime) as work
  FROM [srv-yb-skud].[RusGuardDB].[dbo].[Log] as L
  left join [srv-yb-skud].rusguarddb.dbo.Log as L_start on L_start._id=(select top 1 _id 
					from [srv-yb-skud].rusguarddb.dbo.Log as l_sub
					where l_sub.EmployeeID=L.EmployeeID
					 and datediff(d,0,l_sub.DateTime)=datediff(d,0,l.DateTime)
					-- and l_sub.LogMessageSubType=66 /* вход */
					order by l_sub.DateTime
  )
  left join[srv-yb-skud].rusguarddb.dbo. Driver as dr_st on dr_st._idResource=L_start.DriverID
  left join [srv-yb-skud].rusguarddb.dbo.Property as prop_st on prop_st._idResource =dr_st._idResource and prop_st.PropertyName='name'
  left join [srv-yb-skud].rusguarddb.dbo.Log as L_end on L_end._id=(select top 1 _id 
					from [srv-yb-skud].rusguarddb.dbo.Log as l_sub
					where l_sub.EmployeeID=L.EmployeeID
					 and datediff(d,0,l_sub.DateTime)=datediff(d,0,l.DateTime)
					-- and l_sub.LogMessageSubType=67 /* выход */
					order by l_sub.DateTime desc
  )
  left join [srv-yb-skud].rusguarddb.dbo.Driver as dr_end on dr_end._idResource=L_end.DriverID
  left join [srv-yb-skud].rusguarddb.dbo.Property as prop_end on prop_end._idResource =dr_end._idResource and prop_end.PropertyName='name'
  
  join [srv-yb-skud].rusguarddb.dbo.Employee on Employee._id= L.EmployeeID
  left join [srv-yb-skud].rusguarddb.dbo.EmployeeGroup on EmployeeGroup._id=Employee.EmployeeGroupID
  
  where  datediff(d,0,L.DateTime)=datediff(d,0,@D)


	select @D = @D + 1
end
  
/*  
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[z_skud]') AND type in (N'U'))
DROP TABLE [dbo].[z_skud]
  
select *
into z_skud
from @tbl
*/ 
 
select 
dep,name
,round(sum(
datediff(hh, 0, work ) 
+
cast(DATEPART(MINUTE,work) as float)/60
),2) as hour_sum
,max(case when datepart(DAY,d)=1 then convert(varchar(20),work,108) else '' end) as [1]
,max(case when datepart(DAY,d)=2 then convert(varchar(20),work,108) else '' end) as [2]
,max(case when datepart(DAY,d)=3 then convert(varchar(20),work,108) else '' end) as [3]
,max(case when datepart(DAY,d)=4 then convert(varchar(20),work,108) else '' end) as [4]
,max(case when datepart(DAY,d)=5 then convert(varchar(20),work,108) else '' end) as [5]
,max(case when datepart(DAY,d)=6 then convert(varchar(20),work,108) else '' end) as [6]
,max(case when datepart(DAY,d)=7 then convert(varchar(20),work,108) else '' end) as [7]
,max(case when datepart(DAY,d)=8 then convert(varchar(20),work,108) else '' end) as [8]
,max(case when datepart(DAY,d)=9 then convert(varchar(20),work,108) else '' end) as [9]
,max(case when datepart(DAY,d)=10 then convert(varchar(20),work,108) else '' end) as [10]
,max(case when datepart(DAY,d)=11 then convert(varchar(20),work,108) else '' end) as [11]
,max(case when datepart(DAY,d)=12 then convert(varchar(20),work,108) else '' end) as [12]
,max(case when datepart(DAY,d)=13 then convert(varchar(20),work,108) else '' end) as [13]
,max(case when datepart(DAY,d)=14 then convert(varchar(20),work,108) else '' end) as [14]
,max(case when datepart(DAY,d)=15 then convert(varchar(20),work,108) else '' end) as [15]
,max(case when datepart(DAY,d)=16 then convert(varchar(20),work,108) else '' end) as [16]
,max(case when datepart(DAY,d)=17 then convert(varchar(20),work,108) else '' end) as [17]
,max(case when datepart(DAY,d)=18 then convert(varchar(20),work,108) else '' end) as [18]
,max(case when datepart(DAY,d)=19 then convert(varchar(20),work,108) else '' end) as [19]
,max(case when datepart(DAY,d)=20 then convert(varchar(20),work,108) else '' end) as [20]
,max(case when datepart(DAY,d)=21 then convert(varchar(20),work,108) else '' end) as [21]
,max(case when datepart(DAY,d)=22 then convert(varchar(20),work,108) else '' end) as [22]
,max(case when datepart(DAY,d)=23 then convert(varchar(20),work,108) else '' end) as [23]
,max(case when datepart(DAY,d)=24 then convert(varchar(20),work,108) else '' end) as [24]
,max(case when datepart(DAY,d)=25 then convert(varchar(20),work,108) else '' end) as [25]
,max(case when datepart(DAY,d)=26 then convert(varchar(20),work,108) else '' end) as [26]
,max(case when datepart(DAY,d)=27 then convert(varchar(20),work,108) else '' end) as [27]
,max(case when datepart(DAY,d)=28 then convert(varchar(20),work,108) else '' end) as [28]
,max(case when datepart(DAY,d)=29 then convert(varchar(20),work,108) else '' end) as [29]
,max(case when datepart(DAY,d)=30 then convert(varchar(20),work,108) else '' end) as [30]
,max(case when datepart(DAY,d)=31 then convert(varchar(20),work,108) else '' end) as [31]

from @tbl
group by 
dep,name

--select datepart(DAY,GETDATE())  
  
  
  
  
  
