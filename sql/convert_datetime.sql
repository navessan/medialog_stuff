SELECT [id]
      ,[call_theme]
      ,[call_from]
      ,[call_question]
      ,[call_start]
      ,[call_end]
      ,[call_written]
      ,[call_comment],
 convert(int,
		 substring(
					convert(binary(8),(CAST((call_end - call_start) as datetime)))
					, 5, 4)
		)/1000.0*3.33  call_length
--(3.33 * (convert(int, substring(convert(binary(8), getdate()), 5, 4) ))) / 3600000.0 As hours      
  FROM [col_log].[dbo].[calls]