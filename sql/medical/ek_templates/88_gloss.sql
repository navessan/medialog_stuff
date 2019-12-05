select *
update GLOSS set
Elements=
	(select elements
	from [10.255.69.10].[med_euroonco_new].[dbo].gloss
	where
	base='MOTCONSU#P:591' and
	champ='PATDIREC_DRUGS_NO_GROUPS')
from gloss
where
base='MOTCONSU' and
champ='PATDIREC_DRUGS_NO_GROUPS'



(select elements
from [10.255.69.10].[med_euroonco_new].[dbo].gloss
where
base='MOTCONSU#P:591' and
champ='PATDIREC_DRUGS_NO_GROUPS')