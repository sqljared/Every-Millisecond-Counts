USE [master]
RESTORE DATABASE [AdventureWorks2014] FROM  
	DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\Backup\AdventureWorks2014.bak' 
	WITH  FILE = 1,  NOUNLOAD,  STATS = 5;
GO
