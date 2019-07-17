USE [dbASOMS_Validation]
GO
/****** Object:  UserDefinedFunction [validations].[fnCheckRegionsOfSKU]    Script Date: 7/17/2019 3:44:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tripathi, Shubhang
-- Create date: 16 July 2019
-- Description:	Checks if the region in the SKU is a valid region
--				User story: https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/129
-- =============================================
CREATE FUNCTION [validations].[fnCheckRegionsOfSKU]
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
	[Validation Name] = 'The SKUs region should be valid',	
	[Flagged Column Name] = 'Region Name',
	[Flagged Column Value] = s.[Region Name],
	[Remarks] = 'The SKUs region name is not valid',
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
where 
 e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
AND (s.[Region Name] not in (
select distinct v.[Ref Full Text] from [dbASOMS_Production].[Prod].[vwASOMSRefValidationsRegion] v where v.[Is RefAbbreviation Active] = 'Yes'
UNION 
select distinct vd.[Ref Full Text] from [dbASOMS_Production].[Prod].[vwASOMSRefValidationsDraftRegion] vd where vd.[Is RefAbbreviation Active] = 'Yes'
UNION
select distinct a.[Ref Full Text] from [dbASOMS_Production].[Prod].[vwASOMSRefAbbreviationsRegion] a where a.[Is RefAbbreviation Active] = 'Yes'
)
)

RETURN 
END

