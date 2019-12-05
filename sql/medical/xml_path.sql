
select replace
(
(
 select CIM10_CODE as 'data()' 
 from US_KK203_CIM_GROUPS
for xml path('')
)
, ' ', ', ')