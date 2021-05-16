USE AdventureWorks2014
GO
CREATE OR ALTER PROCEDURE dbo.sp_DetailUpdate
	@SalesOrderID INT,
	@Updates dbo.OrderQtyTVP READONLY,
	@UpdateType INT = 0
AS

DECLARE 
	@OrderStatus INT = 0;

	SELECT
		@OrderStatus = soh.Status
	FROM Sales.SalesOrderHeader soh
	WHERE
		soh.SalesOrderID = @SalesOrderID;

	IF @UpdateType = 1	--Relative
	BEGIN
		UPDATE sod
		SET 
			sod.OrderQty = tvp.OrderQty,
			sod.UnitPrice = tvp.UnitPrice,
			sod.ModifiedDate = GETUTCDATE()
		FROM @Updates tvp
		JOIN Sales.SalesOrderDetail sod
			ON sod.ProductID = tvp.ProductID
			AND sod.SalesOrderID = @SalesOrderID;
			--Removing these comments would show the Halloween Problem!
		--WHERE
		--	sod.OrderQty <> tvp.OrderQty
		--	OR sod.UnitPrice <> tvp.UnitPrice
	END
	ELSE IF @UpdateType = 0	--Absolute
	BEGIN
		UPDATE sod
		SET 
			sod.OrderQty = tvp.OrderQty,
			sod.UnitPrice = ISNULL(tvp.UnitPrice,sod.UnitPrice),
			sod.ModifiedDate = GETUTCDATE()
		FROM @Updates tvp
		INNER JOIN Sales.SalesOrderDetail sod
			ON sod.ProductID = tvp.ProductID
			AND sod.SalesOrderID = @SalesOrderID
		WHERE
			sod.SalesOrderID = @SalesOrderID;
				--Removing these comments would show the Halloween Problem!
			--AND (sod.OrderQty <> 
			--	CASE WHEN tvp.ProductID IS NULL THEN 0
			--		ELSE tvp.OrderQty END
			--	OR sod.UnitPrice = ISNULL(tvp.UnitPrice,sod.UnitPrice));

		DELETE sod
		FROM Sales.SalesOrderDetail sod
		LEFT JOIN @Updates tvp
			ON sod.ProductID = tvp.ProductID
			AND sod.SalesOrderID = @SalesOrderID
		WHERE
			sod.SalesOrderID = @SalesOrderID
			AND ( tvp.ProductID IS NULL);
	END;

	INSERT INTO Sales.SalesOrderDetail
           ([SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice])
     SELECT
           sod.SalesOrderID,
           'sometrackingnumber', --<CarrierTrackingNumber, nvarchar(25),>
           tvp.OrderQty,
           tvp.ProductID,
           0, --SpecialOfferID
           tvp.UnitPrice
	FROM @Updates tvp
	LEFT JOIN Sales.SalesOrderDetail sod
		ON sod.ProductID = tvp.ProductID
		AND sod.SalesOrderID = @SalesOrderID
	WHERE
		sod.ProductID IS NULL;


	RETURN @@ROWCOUNT;
GO
