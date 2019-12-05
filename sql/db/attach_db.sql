CREATE DATABASE [global] ON 
( FILENAME = N'C:\Databases\global.mdf' ),
( FILENAME = N'C:\Databases\global_log.ldf' )
 FOR ATTACH
go


CREATE DATABASE [history] ON 
( FILENAME = N'C:\Databases\history.mdf' ),
( FILENAME = N'C:\Databases\history_log.ldf' )
 FOR ATTACH

go

CREATE DATABASE [local] ON 
( FILENAME = N'C:\Databases\local.mdf' ),
( FILENAME = N'C:\Databases\local_log.ldf' )
 FOR ATTACH