-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tripathi, Shubhang
-- Create date: 26 June 2019
-- Description:	Retuns 1 if tags for a particular SKU has been changed; 0 otherwise
--				Scalar value function added in case more tags need to be compared
-- =============================================
CREATE FUNCTION [validations].[fnCheckMeterForTagChange]
(
	-- Add the parameters for the function here
	@EventID int ,
	@MeterID int 
)
RETURNS bit
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar bit
	
	DECLARE @Count int
	SET @ResultVar = 0
 SELECT @Count= (SELECT COUNT(*) FROM (SELECT DISTINCT *
			   FROM 
			( 
			(SELECT  
			  m.[Has DevTest Percent Change],
			  m.[Has EA Uom Change],
			  m.[Has Graduated Rate Change],
			  m.[Has Consumption Sku], -- Adding a new SKU to the meter - Does it modify the other tags as well? Should we check more for this?
			 m.[Has Incl Qty Decrease],
			 m.[Has Incl Qty Increase],
			 m.[Has Meter Migration],
			 m.[Has Name Change],
			 m.[Has Price Decrease],
			 m.[Has Price Increase],
			 m.[Has Promo Sku],
			 m.[Has Revenue Sku Change]
			 FROM [dbASOMS_Production].[Prod].[vwASOMSMeter] m
			  where ( m.MeterID = @MeterID and m.[Parent id] = @EventID)
			  )		  
			  UNION ALL
			 (SELECT  
			  mh.[Has DevTest Percent Change],
			  mh.[Has EA Uom Change],
			  mh.[Has Graduated Rate Change],
			  mh.[Has Consumption Sku],
			 mh.[Has Incl Qty Decrease],
			 mh.[Has Incl Qty Increase],
			 mh.[Has Meter Migration],
			 mh.[Has Name Change],
			 mh.[Has Price Decrease],
			 mh.[Has Price Increase],
			 mh.[Has Promo Sku],
			 mh.[Has Revenue Sku Change]
			 FROM [dbASOMS_Production].[Prod].[vwASOMSMeterHist] mh
			Where (mh.MeterID = @MeterID and mh.EventID = @EventID)
			)
			) as tempTable
) as tempTable2)
	
	IF (@Count > 1) SET @ResultVar = 1

	

	-- Return the result of the function
	RETURN @ResultVar

END
GO

