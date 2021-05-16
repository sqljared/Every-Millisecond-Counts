USE AdventureWorks2014
GO
DECLARE @Updates dbo.OrderQtyTVP;
DECLARE @SalesOrderID INT = 0;

--Redundant logic and CTE
WITH too_much AS(
	SELECT 
		CASE WHEN tvp.ProductID IS NULL THEN sod.ProductID ELSE tvp.ProductID END AS ProductID,
		CASE WHEN tvp.OrderQty IS NULL THEN sod.OrderQty ELSE tvp.OrderQty END AS OrderQty,
		CASE WHEN tvp.UnitPrice IS NULL THEN sod.UnitPrice ELSE tvp.UnitPrice END AS UnitPrice
	FROM Sales.SalesOrderDetail sod
	LEFT JOIN @Updates tvp 
		ON sod.ProductID = tvp.ProductID
	WHERE sod.SalesOrderID = @SalesOrderID
	)
UPDATE sod
SET 
	sod.OrderQty = CASE WHEN soh.ShipDate IS NULL THEN tm.OrderQty ELSE sod.OrderQty END,
	sod.UnitPrice = CASE WHEN soh.ShipDate IS NULL THEN tm.UnitPrice ELSE sod.UnitPrice END,
	sod.ModifiedDate = CASE WHEN soh.ShipDate IS NULL THEN GETUTCDATE() ELSE soh.ModifiedDate END
FROM too_much tm
JOIN Sales.SalesOrderDetail sod
	ON sod.ProductID = tm.ProductID
JOIN Sales.SalesOrderHeader soh
	ON soh.SalesOrderID = sod.SalesOrderID
WHERE 
	sod.SalesOrderID = @SalesOrderID;
	

--Without extraneous logic
UPDATE sod
SET 
	sod.OrderQty = CASE WHEN soh.ShipDate IS NULL THEN 
			CASE WHEN tvp.OrderQty IS NULL THEN sod.OrderQty ELSE tvp.OrderQty END
		ELSE sod.OrderQty END,
	sod.UnitPrice = CASE WHEN soh.ShipDate IS NULL THEN 
			CASE WHEN tvp.UnitPrice IS NULL THEN sod.UnitPrice ELSE tvp.UnitPrice END
		ELSE sod.OrderQty END,
	sod.ModifiedDate = CASE WHEN soh.ShipDate IS NULL THEN GETUTCDATE() ELSE soh.ModifiedDate END
FROM Sales.SalesOrderDetail sod
LEFT JOIN @Updates tvp
	ON sod.ProductID = tvp.ProductID
JOIN Sales.SalesOrderHeader soh
	ON soh.SalesOrderID = sod.SalesOrderID
WHERE 
	sod.SalesOrderID = @SalesOrderID;
GO