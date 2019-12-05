declare @P1 int
declare @P2 int

declare @medecins_ID int

DECLARE cur CURSOR FOR
SELECT 
medecins_ID
FROM
 medecins
WHERE
medecins_id not in(
	SELECT medecins_ID
	FROM medecins_info
	)
-------------------

OPEN Cur;
FETCH NEXT FROM Cur into @medecins_ID;
WHILE @@FETCH_STATUS = 0
   BEGIN
-----------------------------------------------------------------------------
exec up_get_id  @KeyName = 'MEDECINS_INFO', @Shift = 1, @ID = @P1 output

BEGIN TRANSACTION;
insert into MEDECINS_INFO
(MEDECINS_INFO_ID,medecins_ID)
values(@P1,@medecins_ID)
COMMIT TRANSACTION;
------------------------
      FETCH NEXT FROM Cur into @medecins_ID;
   END;
CLOSE Cur;
DEALLOCATE Cur;

