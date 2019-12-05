/*
truncate table US_OMS_DEP_LINK
insert into US_OMS_DEP_LINK
(id,fm_dep_id)
select fm_dep_id,fm_dep_id from fm_dep
*/
update US_OMS_DEP_LINK
set usl_cl1900=5