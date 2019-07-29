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
-- Create date: 29 July 2019
-- Description:	Returns a list of Dev/Test Meters which do not have source meter GUID
--				More description could be found at https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/116
-- =============================================
ALTER FUNCTION [validations].[fnCheckSourceMeterGUIDForModDevTestMeters]
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

	[Validation Name] = 'DevTest eligible for "modifies" must have a Source meter GUID',	
	[Flagged Column Name] = 'Meter DevTest Rate Source Meter ID',
	[Flagged Column Value] = m.[DevTest Rate Source Meter ID],							 
	[Remarks] = 'No source meter for DevTest modify for SKU with MeterID '+CAST(m.MeterID as nvarchar(max)),
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
		
	
FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
where 
		
		(m.[Has DevTest Sku] = 'Yes' AND s.[Is New Sku] = 'No')
and		
		(ISNULL(m.[DevTest Rate Source Meter ID], '') = '' ) 

and     e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight

RETURN 
END
GO
