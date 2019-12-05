/*
create database medialog7_back_truncated on
(name='medialog_data',
FILENAME='d:\data\sql\medialog7_back_truncated.ss')
AS SNAPSHOT OF medialog7_back
*/
------------------
RESTORE DATABASE medialog7_back FROM DATABASE_SNAPSHOT = 'medialog7_back_truncated'