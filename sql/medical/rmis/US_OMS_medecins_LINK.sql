
--truncate table US_OMS_medecins_LINK
insert into US_OMS_medecins_LINK
(id,medecins_id)
select medecins_id,medecins_id from medecins
where isnull(archive,0)=0
--update US_OMS_DEP_LINK set usl_cl1900=5