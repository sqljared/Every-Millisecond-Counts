USE AdventureWorks2014
GO
IF NOT EXISTS(
	SELECT 1 
	FROM sys.types st
	WHERE 
		st.name = 'OrderQtyTVP'
)
BEGIN
	CREATE TYPE dbo.OrderQtyTVP 
	AS TABLE(
		ProductID INT,
		OrderQty SMALLINT,
		UnitPrice MONEY,
		INDEX IX_OrderQtyTVP NONCLUSTERED (ProductID)
	)WITH(MEMORY_OPTIMIZED = ON); 
END;
GO

IF NOT EXISTS(
	SELECT 1 
	FROM sys.types st
	WHERE 
		st.name = 'OrderQtyModTVP'
)
BEGIN
	CREATE TYPE dbo.OrderQtyModTVP 
	AS TABLE(
		ProductID INT,
		OrderQty_New SMALLINT NULL,
		UnitPrice_New MONEY NULL,
		OrderQty_Current SMALLINT NULL,
		UnitPrice_Current MONEY NULL,
		INDEX IX_OrderQtyTVP NONCLUSTERED (ProductID)
	)WITH(MEMORY_OPTIMIZED = ON); 
END;
GO

--DROP PROCEDURE IF EXISTS dbo.sp_DetailUpdate;
--DROP PROCEDURE IF EXISTS dbo.sp_DetailUpdate_Modified;

--DROP TYPE dbo.OrderQtyModTVP;
--DROP TYPE dbo.OrderQtyTVP;