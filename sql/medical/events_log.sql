SELECT top 1000
[TABLE_NAME]
      ,[REC_ID]
      ,[USER_ID]
      ,[DATE_CHANGE]
      ,[ACTION]
      ,[LOG]
--      ,[LOG_DATA]
		,name
		,nom
		,specialisation
		,archive
  FROM KRN_SYS_TRACE_LOG
--join MEDECINS on KRN_SYS_TRACE_LOG.USER_ID = MEDECINS.MEDECINS_ID
left join sys.database_principals on KRN_SYS_TRACE_LOG.USER_ID= sys.database_principals.principal_id
left join medecins on sys.database_principals.name=medecins.login
where 
table_name='fm_bill' and rec_id in (3268100,3268115)
order by date_change --desc
