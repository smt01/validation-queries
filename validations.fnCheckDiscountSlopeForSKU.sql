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
-- Create date: 31 July 2019
-- Description:	Returns SKUs which do not have their discount slope as 0/0/0/0
--				More description could be found at https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/137
-- =============================================
CREATE FUNCTION [validations].[fnCheckDiscountSlopeForSKU]
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
		INSERT into @rtnTable
		SELECT
		[Event ID] = e.[ID],
		[Work Item Type] = 'Consumption SKU',
	[Work Item ID] = s.ConsumptionSkuID,

	[Validation Name] = 'New SKUs with an invalid discount slope',	
	[Flagged Column Name] = 'SKU Discount Slope',
	[Flagged Column Value] = s.[Discount Slope],							 
	[Remarks] = 'SKU should not have non-zero discount slope',
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
		
	
FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
where 
		
		(s.[Is New Sku] = 'Yes' AND s.[Discount Slope] <> '0/0/0/0')


and     e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight

RETURN 
END
GO
