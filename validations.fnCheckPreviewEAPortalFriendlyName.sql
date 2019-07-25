USE [dbASOMS_Validation]
GO
/****** Object:  UserDefinedFunction [validations].[fnCheckPreviewEAPortalFriendlyName]    Script Date: 7/25/2019 12:43:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tripathi,Shubhang
-- Create date: 7'th June 2019
-- Description:	Checks for the presence of the word 'Preview' in EA Portal Friendly name
--				Returns records where :
--				(s.[EA Portal Friendly Name]  LIKE '%PREVIEW%' AND s.[SAP Sku Sub Type] NOT LIKE '%PREVIEW%')
--			     OR
--				(s.[EA Portal Friendly Name] NOT LIKE '%PREVIEW' AND s.[SAP Sku Sub Type] LIKE '%PREVIEW%')
-- =============================================
ALTER FUNCTION [validations].[fnCheckPreviewEAPortalFriendlyName]
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
	[Validation Name] = CASE WHEN (ISNULL(s.[EA Portal Friendly Name],'') = '') THEN 'EA Portal Friendly Name should sot be blank'
						ELSE 'If SKU sub-type is Preview then EA Portal Name needs to have the word Preview' END
	,	
	[Flagged Column Name] = CASE WHEN ( s.[EA Portal Friendly Name]  LIKE '%PREVIEW%' AND s.[Launch Stage] NOT LIKE '%PREVIEW%') 
							THEN 'SKU Launch Stage' ELSE
							CASE WHEN  (s.[EA Portal Friendly Name] NOT LIKE '%PREVIEW%' AND s.[Launch Stage] LIKE '%PREVIEW%')
							THEN 'EA Portal Friendly Name' END
							END,
	[Flagged Column Value] = CASE WHEN ( s.[EA Portal Friendly Name]  LIKE '%PREVIEW%' AND s.[Launch Stage] NOT LIKE '%PREVIEW%') 
							THEN s.[Launch Stage] 
							ELSE CASE WHEN  (s.[EA Portal Friendly Name] NOT LIKE '%PREVIEW%' AND s.[Launch Stage] LIKE '%PREVIEW%')
							THEN s.[EA Portal Friendly Name] END
							END,
	[Remarks] = CASE WHEN ( s.[EA Portal Friendly Name]  LIKE '%PREVIEW%' AND s.[Launch Stage] NOT LIKE '%PREVIEW%') 
							THEN 'SKU Launch Stage does not contain the word Preview'
							ELSE CASE WHEN (ISNULL(s.[EA Portal Friendly Name],'') = '') THEN 'EA Portal Friendly name should not be blank' 
							ELSE CASE WHEN  (s.[EA Portal Friendly Name] NOT LIKE '%PREVIEW%' AND s.[Launch Stage] LIKE '%PREVIEW%')
							THEN 'EA Portal Friendly Name does not contain the word Preview' END
							END
							END,
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
		(s.[EA Portal Friendly Name]  LIKE '%PREVIEW%' AND s.[Launch Stage] NOT LIKE '%PREVIEW%') 
	OR
	(s.[EA Portal Friendly Name] NOT LIKE '%PREVIEW%' AND s.[Launch Stage] LIKE '%PREVIEW%')
	)
	AND e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight

RETURN 
END
