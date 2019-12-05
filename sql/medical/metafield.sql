select
case
 when datatype=1 then 'link'
 when datatype=3 then 'varchar'
 when datatype=4 then 'date'
 when datatype=9 then 'text memo'
 when datatype=11 then 'logical'
end medtype
,* from metafield
where 
table_name like 'motconsu'
--and datatype=9
--and custom like '%v01%'
order by ord