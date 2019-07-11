-- ================================================
-- Template generated from Template Explorer using:
-- Create Multi-Statement Function (New Menu).SQL
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
-- Create date: 25 June 2019
-- Description:	Returns SKU's which are 
--				1.new and have part numbers (they should not)
--				2.Not new/ modified and does not have Part Number
--				User story here: https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/123
-- =============================================
CREATE FUNCTION [validations].[fnCheckSKUAndPartNumber]
(
	
)
 
RETURNS @rtnTable TABLE (
	[Event ID] INT NULL,
	[Work Item Type] nvarchar(max) null,
	[Work Item ID] INT NULL,
	[Validation Name] nvarchar(max) NOT NULL,	
	[Flagged Column Name] nvarchar(max) NULL,
	[Flagged Column Value] nvarchar(max) null,
	[Remarks] nvarchar(max) NULL,
	[SKU State] nvarchar(max) NULL,	
	[SAP Rate Start Date] datetime NULL,
	[Cayman Release] nvarchar(max) NULL,	
	[Meter Status] nvarchar(max) NULL
	
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	INSERT INTO @rtnTable
SELECT 
[Event ID] = e.[ID],
[Work Item Type] = 'Consumption SKU',
	[Work Item ID] = s.[ConsumptionSkuID],	
	[Validation Name] = 'SKU status and Part Number',	
	[Flagged Column Name] = 'SKU Part Number',
	[Flagged Column Value] = s.[Part Number],
	[Remarks] = CASE WHEN 	(s.[Is New Sku] = 'Yes' and s.[Part Number] is NOT NULL)							
							THEN 'For a new SKU, part number should be null instead of: '+ s.[Part Number]
							ELSE CASE WHEN (s.[Is New Sku] = 'No' and s.[Part Number] is NULL)
							THEN 'For a Modified SKU,the part number should not be null' END
							END,
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKU] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
where 
((s.[Is New Sku] = 'Yes' and s.[Part Number] is NOT NULL) 
OR
(s.[Is New Sku] = 'No' and s.[Part Number] is NULL))
and e.[Sap Publish Status] <> 'Committed'

AND e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
	RETURN 
END
GO