
SELECT top 1
(COUNT(DISTINCT FM_BILL.PATIENTS_ID )) CNT_PAT,(COUNT(FM_BILL.FM_BILL_ID )) CNT_BILL
FROM
 FM_BILL FM_BILL
where FM_BILL.BILL_DATE=DATEADD(day, DATEDIFF(day, 0, getdate()), 0)
GROUP BY
 FM_BILL.BILL_DATE
