USE [dbASOMS_Validation]
GO
/****** Object:  UserDefinedFunction [validations].[fnCheckMeterForTagChange]    Script Date: 7/3/2019 10:50:31 AM ******/
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
			 m.[Has Incl Qty Decrease],
			 m.[Has Incl Qty Increase],
			 m.[Has Meter Migration],
			 m.[Has Name Change],
			 m.[Has Price Decrease],
			 m.[Has Price Increase],			 
			 m.[Has Revenue Sku Change]
			 FROM [dbASOMS_Production].[Prod].[vwASOMSMeter] m
			  where ( m.MeterID = @MeterID and m.[Parent id] = @EventID)
			  )		  
			  UNION ALL
			 (SELECT  
			  mh.[Has DevTest Percent Change],
			  mh.[Has EA Uom Change],
			  mh.[Has Graduated Rate Change],			 
			 mh.[Has Incl Qty Decrease],
			 mh.[Has Incl Qty Increase],
			 mh.[Has Meter Migration],
			 mh.[Has Name Change],
			 mh.[Has Price Decrease],
			 mh.[Has Price Increase],			 
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
