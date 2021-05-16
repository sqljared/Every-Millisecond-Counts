USE AdventureWorks2014
GO
CREATE OR ALTER PROCEDURE dbo.sp_DetailUpdate_Modified
@SalesOrderID INT,
@Updates dbo.OrderQtyTVP READONLY,
@UpdateType INT = 0
AS

DECLARE @DetailChanges dbo.OrderQtyModTVP;
DECLARE @OrderStatus INT = 0;

	SELECT
		@OrderStatus = soh.Status
	FROM Sales.SalesOrderHeader soh
	WHERE
		soh.SalesOrderID = @SalesOrderID;

	IF @UpdateType = 1	--Incremental
	BEGIN
	
		INSERT INTO @DetailChanges
		SELECT
			tvp.ProductID,
			tvp.OrderQty,
			tvp.UnitPrice,
			sod.OrderQty,
			sod.UnitPrice
		FROM @Updates tvp
		LEFT JOIN Sales.SalesOrderDetail sod WITH(INDEX(IX_SalesOrderDetail_ProductID))
			ON sod.ProductID = tvp.ProductID
			AND sod.SalesOrderID = @SalesOrderID;

		IF EXISTS(
			SELECT 1
			FROM @DetailChanges dc
			WHERE
				dc.OrderQty_Current <> dc.OrderQty_New
				OR dc.UnitPrice_Current <> dc.UnitPrice_New
		)
		BEGIN
			UPDATE sod
			SET 
				sod.OrderQty = dc.OrderQty_New,
				sod.UnitPrice = dc.UnitPrice_New,
				sod.ModifiedDate = GETUTCDATE()
			FROM @DetailChanges dc
			INNER JOIN Sales.SalesOrderDetail sod
				ON sod.ProductID = dc.ProductID
				AND sod.SalesOrderID = @SalesOrderID
			WHERE
				dc.OrderQty_New <> dc.OrderQty_Current
				OR dc.UnitPrice_New <> dc.UnitPrice_Current;
		END;
	END
	ELSE IF @UpdateType = 0	--Full
	BEGIN

		INSERT INTO @DetailChanges
		SELECT
			tvp.ProductID,
			tvp.OrderQty,
			tvp.UnitPrice,
			sod.OrderQty,
			sod.UnitPrice
		FROM @Updates tvp
		FULL JOIN Sales.SalesOrderDetail sod WITH(INDEX(IX_SalesOrderDetail_ProductID))
			ON sod.ProductID = tvp.ProductID
			AND sod.SalesOrderID = @SalesOrderID
		WHERE 
			sod.SalesOrderID = @SalesOrderID;
			
		IF EXISTS(
			SELECT 1
			FROM @DetailChanges dc
			WHERE
				dc.OrderQty_Current <> dc.OrderQty_New
				OR dc.UnitPrice_Current <> dc.UnitPrice_New
		)
		BEGIN
			UPDATE sod
			SET 
				sod.OrderQty = dc.OrderQty_New,
				sod.UnitPrice = dc.UnitPrice_New,
				sod.ModifiedDate = GETUTCDATE()
			FROM @DetailChanges dc
			INNER JOIN Sales.SalesOrderDetail sod
				ON sod.ProductID = dc.ProductID
				AND sod.SalesOrderID = @SalesOrderID
			WHERE
				sod.SalesOrderID = @SalesOrderID
				AND ( dc.OrderQty_New <> dc.OrderQty_Current
					OR dc.UnitPrice_New <> dc.UnitPrice_Current);
		END;

		IF EXISTS(
			SELECT 1
			FROM @DetailChanges dc
			WHERE
				dc.OrderQty_New IS NULL
				AND dc.UnitPrice_New IS NULL
		)
		BEGIN
			DELETE sod
			FROM Sales.SalesOrderDetail sod
			LEFT JOIN @DetailChanges dc
				ON sod.ProductID = dc.ProductID
				AND sod.SalesOrderID = @SalesOrderID
			WHERE
				sod.SalesOrderID = @SalesOrderID
				AND ( dc.OrderQty_Current IS NULL
					AND dc.UnitPrice_Current IS NULL);
		END;
	END;

	IF EXISTS(
		SELECT 1
		FROM @DetailChanges dc
		WHERE
			dc.OrderQty_Current IS NULL
			OR dc.UnitPrice_Current IS NULL
	)
	BEGIN
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
	END;

	RETURN @@ROWCOUNT;
GO
