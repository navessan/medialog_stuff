
SELECT distinct
 FM_ACCOUNT_TRAN.FM_ACCOUNT_TRAN_ID
,FM_ACCOUNT_TRAN.TRAN_DATE 
,-FM_ACCOUNT_TRAN.TRAN_SUM	as TRAN_SUM
,TRAN_X.TRAN_TYPE
,TRAN_X.FM_CONTR_ID
,(case when TRAN_X.FM_CONTR_ID is not null then
(SELECT TOP 1 FM_CLINK_PATIENTS.PATIENTS_ID
FROM
 FM_CLINK_PATIENTS  WITH(NOLOCK)  
 JOIN FM_CLINK WITH(NOLOCK) ON FM_CLINK.FM_CLINK_ID = FM_CLINK_PATIENTS.FM_CLINK_ID 
 where FM_CLINK.FM_CONTR_ID =TRAN_X.FM_CONTR_ID
)end) find_pat
,coalesce(FM_BILL.PATIENTS_ID,FM_INVOICE.PATIENTS_ID,FM_ORG.PATIENTS_ID) PATIENTS_ID
,FM_INVOICE.FM_INVOICE_ID
FROM
 FM_INVOICE FM_INVOICE 
 LEFT OUTER JOIN FM_PAYMENTS FM_PAYMENTS ON FM_INVOICE.FM_INVOICE_ID = FM_PAYMENTS.FM_INVOICE_ID 
 JOIN FM_BILLDET_PAY FM_BILLDET_PAY WITH(NOLOCK)  ON FM_BILLDET_PAY.FM_BILLDET_PAY_ID = FM_PAYMENTS.FM_BILLDET_PAY_ID 
 JOIN FM_BILLDET FM_BILLDET WITH(NOLOCK)  ON FM_BILLDET.FM_BILLDET_ID = FM_BILLDET_PAY.FM_BILLDET_ID 
 JOIN FM_BILL FM_BILL WITH(NOLOCK)  ON FM_BILL.FM_BILL_ID = FM_BILLDET.FM_BILL_ID 
 LEFT OUTER JOIN FM_ACCOUNT_TRAN FM_ACCOUNT_TRAN ON FM_ACCOUNT_TRAN.FM_ACCOUNT_TRAN_ID = FM_PAYMENTS.FM_ACCOUNT_TRAN_ID 
 LEFT OUTER JOIN FM_ACCOUNT_TRAN TRAN_X ON FM_ACCOUNT_TRAN.FM_MAIN_TRAN_ID = TRAN_X.FM_ACCOUNT_TRAN_ID 
 LEFT OUTER JOIN FM_ORG FM_ORG ON FM_ORG.FM_ORG_ID = FM_INVOICE.FM_ORG_ID 
WHERE
 FM_ACCOUNT_TRAN.TRAN_TYPE in ('Y','P')  /* "Зачисление аванса","Оплата оказанных услуг" */
 and TRAN_X.FM_TRAN_CREDIT_ID is null /* без переводов с других ЛС*/
 AND datediff(day,FM_ACCOUNT_TRAN.TRAN_DATE,GETDATE())<2
/*LookupKeys=X,Y,Z,A,B,P,U,I,O,Q,R,S,T,J,K,W,D,N,F
LookupValues=
X - "Внесение аванса",
Y - "Зачисление аванса",
Z - "Списание аванса",
A - "Внесение суммы на ЛС",
B - "Возврат суммы",
P - "Оплата оказанных услуг",
U - "Отмена оплаты услуг",
I - "Перевод  с другого ЛС",
O - "Перевод на другой ЛС",
J - "Оплата услуг с использованием аванса",
K - "Отмена оплаты услуг с использованием аванса",
W - "Возврат аванса",
D - "Кредиторская задолженность",
N - "Списание кредиторской задолженности",
F - "Возврат суммы для зачисления аванса"*/