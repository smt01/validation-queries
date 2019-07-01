USE [dbASOMS_Validation]
GO
/****** Object:  UserDefinedFunction [validations].[fnCheckSKUTagChangeOnModify]    Script Date: 6/28/2019 3:37:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tripathi, Shubhang
-- Create date: <Create Date,,>
-- Description:	Validations for Story 124: https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/124
-- =============================================
CREATE FUNCTION [validations].[fnCheckSKUTagChangeOnModify](
	
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
	[Validation Name] = 'A modified SKU should have at least one change tag marked',	
	[Flagged Column Name] = 'Is New Sku',
	[Flagged Column Value] = s.[Is New Sku],
	[Remarks] = 'No tags have been modified for this SKU. Meter ID = '+ CAST( m.MeterID as nvarchar(max)),
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKU] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
	Where
	e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight 
	AND (s.[Is New Sku] = 'No')
	AND ([dbASOMS_Validation].[validations].[fnCheckSKUForTagChange](e.EventID, m.MeterID, s.ConsumptionSkuID) <> 1)

	RETURN 
END
