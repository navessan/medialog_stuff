
rem file base backups
forfiles /p "C:\data\backup\FS" /s /m *.zip /d -1 /C "cmd /c del @path"

rem diff sql bak
forfiles /p "C:\data\backup\SQL" /s /m *diff.bak /d -2 /C "cmd /c del @path"

rem log sql back
forfiles /p "C:\data\backup\SQL" /s /m *.trn /d -1 /C "cmd /c del @path"

rem full sql back
forfiles /p "C:\data\backup\SQL" /s /m *full.bak /d -8 /C "cmd /c del @path"

