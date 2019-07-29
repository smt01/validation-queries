USE [dbASOMS_Validation]
GO
/****** Object:  UserDefinedFunction [validations].[fnMaterialDescriptionShouldBeginWithAZ]    Script Date: 6/7/2019 11:25:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tripathi,Shubhang
-- Create date: 29 July 2019
-- Description:	Returns a list of SKU's whose Material Description field is blank
--              https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/120/
-- =============================================
CREATE FUNCTION [validations].[fnCheckMatDesIsEmptyOrNull]
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
	-- SELECT LOGIC HERE

	INSERT INTO @rtnTable
	SELECT 
	[Event ID] = e.[ID],
	[Work Item Type] = 'Consumption SKU',
	[Work Item ID] = s.[ConsumptionSkuID],	
	[Validation Name] = 'SKU Material Description should not be blank ',	
	[Flagged Column Name] = 'SKU Material Description',
	[Flagged Column Value] = s.[Material Description],
	[Remarks] = 'The SKU Material Description should not be blank',
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]

	FROM [dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[ID] 
	where (s.[State]) not in ('New', 'Cancelled', 'On Hold')

	AND  (ISNULL(s.[Material Description], '') = '')
	
	AND e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
	RETURN 
END
