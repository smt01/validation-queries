USE [dbASOMS_Validation]
GO
/****** Object:  UserDefinedFunction [validations].[fnCheckPreviewEAPortalFriendlyName]    Script Date: 7/25/2019 12:43:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tripathi,Shubhang
-- Create date: 25 July 2019
-- Description:	Checks if an SKU's EA Portal Friendly Name is a blank string
-- =============================================
CREATE FUNCTION [validations].[fnCheckEAPortalFriendlyNameIsEmpty]
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
	[Validation Name] =  'EA Portal Friendly Name should not be blank',	
	[Flagged Column Name] =  'EA Portal Friendly Name',
	[Flagged Column Value] = s.[EA Portal Friendly Name],
	[Remarks] = 'EA Portal Friendly name should not be blank',
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	
FROM 
	[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) JOIN 
	[dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] JOIN
	[dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[ID] 
WHERE
	(
	ISNULL(s.[EA Portal Friendly Name],'') = '' 
	)
	AND e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight

RETURN 
END
