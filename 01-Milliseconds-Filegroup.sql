USE AdventureWorks2014
GO
--EXEC sp_configure filestream_access_level, 2  
--RECONFIGURE
IF NOT EXISTS(
	SELECT 1 
	FROM sys.filegroups fg
	WHERE 
		fg.name = 'AdventureWorks2014_imoltp'
)
BEGIN
	ALTER DATABASE AdventureWorks2014 
		ADD FILEGROUP AdventureWorks2014_imoltp CONTAINS MEMORY_OPTIMIZED_DATA;
END;
GO
IF NOT EXISTS(
	SELECT 1
	FROM sys.database_files df
	WHERE 
		df.name = 'AdventureWorks2014_imoltp_f1'
)
BEGIN
	ALTER DATABASE AdventureWorks2014 
		ADD FILE (name='AdventureWorks2014_imoltp_f1', 
			filename='C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\AdventureWorks2014_imoltp') 
		TO FILEGROUP AdventureWorks2014_imoltp;
END;
GO
