USE AdventureWorks2014
GO
SET NOCOUNT ON;
go
DECLARE
	@SalesOrderID INT = 47000,
	@Updates dbo.OrderQtyTVP,
	@UpdateType INT = 0,	--0 full update; 1 incremental
	@RowsAffected INT = 0, 
	@RowsAffectedMod INT = 0; 

INSERT INTO @Updates
SELECT 
	sod.ProductID,
	sod.OrderQty,
	sod.UnitPrice
FROM Sales.SalesOrderDetail sod
WHERE
	sod.SalesOrderID = @SalesOrderID;

SELECT * 
FROM @Updates;

BEGIN TRANSACTION;

	EXEC @RowsAffected =  dbo.sp_DetailUpdate
		@SalesOrderID = @SalesOrderID,
		@Updates = @Updates,
		@UpdateType = @UpdateType;

	SELECT @RowsAffected AS RowsAffected;

	SELECT 	*
	FROM @Updates tvp
	JOIN Sales.SalesOrderDetail sod
		ON sod.ProductID = tvp.ProductID
		AND sod.SalesOrderID = @SalesOrderID;

ROLLBACK TRANSACTION;

UPDATE upd
SET
	OrderQty = OrderQty 
FROM @Updates upd;

BEGIN TRANSACTION;

	EXEC @RowsAffectedMod =  dbo.sp_DetailUpdate_Modified
		@SalesOrderID = @SalesOrderID,
		@Updates = @Updates,
		@UpdateType = @UpdateType;

	SELECT @RowsAffectedMod AS RowsAffected;

	SELECT 	*
	FROM @Updates tvp
	JOIN Sales.SalesOrderDetail sod
		ON sod.ProductID = tvp.ProductID
		AND sod.SalesOrderID = @SalesOrderID;

ROLLBACK TRANSACTION;
GO 10

--Key Lookup