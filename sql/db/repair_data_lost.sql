ALTER DATABASE NuzBuh8_1 SET SINGLE_USER;

GO

DBCC CHECKDB (NuzBuh8_1, REPAIR_ALLOW_DATA_LOSS) WITH NO_INFOMSGS;

GO

ALTER DATABASE NuzBuh8_1 SET MULTI_USER;

GO