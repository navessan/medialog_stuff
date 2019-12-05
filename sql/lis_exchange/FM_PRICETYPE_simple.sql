/*  ����� ���� ���� */
declare @FM_CLINK_ID int
set @FM_CLINK_ID = 12203

SELECT top 1
FM_PRICETYPE.FM_PRICETYPE_ID
,FM_PRICETYPE.LABEL
FROM
FM_CLINK FM_CLINK 
 LEFT OUTER JOIN FM_CLINK_PROG FM_CLINK_PROG ON FM_CLINK.FM_CLINK_ID = FM_CLINK_PROG.FM_CLINK_ID
 INNER JOIN FM_PROG_SERV FM_PROG_SERV ON (FM_CLINK.FM_CLINK_ID = FM_PROG_SERV.FM_CLINK_ID or FM_CLINK_PROG.FM_PROG_ID = FM_PROG_SERV.FM_PROG_ID)
 LEFT OUTER JOIN FM_PRICETYPE FM_PRICETYPE on FM_PROG_SERV.FM_PRICETYPE_ID = FM_PRICETYPE.FM_PRICETYPE_ID
WHERE
 (FM_CLINK.FM_CLINK_ID  = @FM_CLINK_ID)
 and FM_PRICETYPE.FM_PRICETYPE_ID in(1,6) /* base and oms*/