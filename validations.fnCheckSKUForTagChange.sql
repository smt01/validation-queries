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
CREATE FUNCTION [validations].[fnCheckSKUForTagChange]
(
	-- Add the parameters for the function here
	@EventID int ,
	@MeterID int ,
	@SKUID int 
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
			  s.[Has Discount Slope Changed],
			  s.[Has Ea Portal Changed],  
			  s.[Has Ea Rate Decreased],
			  s.[Has Ea Rate Increased],
			  s.[Has Ea Uom Changed],
			  s.[Has Included Quantity Changed], 
			  s.[Has Material Description Changed],
			  s.[Has Public Status Date Changed] 
			  FROM [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKU] s
			  where (s.ConsumptionSkuID = @SKUID and s.MeterID = @MeterID and s.EventID = @EventID)
			  )		  
			  UNION ALL
			 (SELECT  
			 sh.[Has Discount Slope Changed],
			 sh.[Has Ea Portal Changed], 
			 sh.[Has Ea Rate Decreased] ,
			 sh.[Has Ea Rate Increased],
			 sh.[Has Ea Uom Changed], 
			 sh.[Has Included Quantity Changed],
			 sh.[Has Material Description Changed] ,
			 sh.[Has Public Status Date Changed]
			 FROM [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHIST] sh
			Where (sh.ConsumptionSkuID = @SKUID and sh.MeterID = @MeterID and sh.EventID = @EventID)
			)
			) as tempTable
) as tempTable2)
	
	IF (@Count > 1) SET @ResultVar = 1

	

	-- Return the result of the function
	RETURN @ResultVar

END
GO

