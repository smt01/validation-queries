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
-- Create date: 24 June 2019
-- Description:	Checks if a newly created SKU has a Discontinue Date
--				User story: https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/121
-- =============================================
CREATE FUNCTION [validations].[fnCheckNewSKUShouldNotHaveDiscontinueDate] 
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
	[Validation Name] = 'A newly created SKU should not have a discontinue date',	
	[Flagged Column Name] = 'SAP Discontinue Date',
	[Flagged Column Value] = CASE WHEN (s.[SAP Discontinue Date] is NULL or s.[SAP Discontinue Date] = ' ')THEN ' ' ELSE CAST(s.[SAP Discontinue Date] as date) END,
	[Remarks] = CASE WHEN (
							s.[Is New Sku] = 'Yes'  and (s.[SAP Discontinue Date] is NOT NULL)
							)
							THEN 'For a new SKU, SAP Discontinue date should be either null or 12/31/2030 instead of'+ CAST(CAST(s.[SAP Discontinue Date] as date) as nvarchar(max))
							
							END,
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeter] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKU] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
where 
s.[Is New Sku] = 'Yes'  and (s.[SAP Discontinue Date] is NOT NULL)-- OR s.[SAP Discontinue Date] <> 12/31/2020)
AND e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
RETURN 
END

GO