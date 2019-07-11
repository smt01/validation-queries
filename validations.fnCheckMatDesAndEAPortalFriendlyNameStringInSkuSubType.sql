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
-- Create date: 21 June 2019
-- Description:	Promo/DevTest included in naming fields
--				More details here: https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/138
-- =============================================
-- Check for possible DvTst spellings

CREATE FUNCTION [validations].[fnCheckMatDesAndEAPortalFriendlyNameStringInSkuSubType]
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
	[Validation Name] = 'If SKU sub-type is Promo or DevTest then Material Description and EA Portal Friendly Name should have the same',	
	[Flagged Column Name] = CASE WHEN (
							(s.[SKu Sub Type] = 'Promo' and s.[Material Description] NOT LIKE '%Promo%' 
							OR
							s.[SKu Sub Type] = 'DevTest' and (s.[Material Description] NOT LIKE '%DevTest%' AND s.[Material Description] NOT LIKE '%DvTst%') )
							)THEN 'SKU Material Description' ELSE
							CASE WHEN (
							(s.[SKu Sub Type] = 'Promo' and s.[EA Portal Friendly Name] NOT LIKE '%Promo%' 
							OR
							s.[SKu Sub Type] = 'DevTest' and (s.[EA Portal Friendly Name] NOT LIKE '%DevTest%' AND s.[EA Portal Friendly Name] NOT LIKE '%Dev/Test%' ) )
							)
							THEN 'EA Portal Friendly Name' END
							END,
	[Flagged Column Value] = CASE WHEN (
							(s.[SKu Sub Type] = 'Promo' and s.[Material Description] NOT LIKE '%Promo%' 
							OR
							s.[SKu Sub Type] = 'DevTest' and (s.[Material Description] NOT LIKE '%DevTest%' AND s.[Material Description] NOT LIKE '%DvTst%') )
							)
							THEN s.[Material Description]
							ELSE CASE WHEN (
							(s.[SKu Sub Type] = 'Promo' and s.[EA Portal Friendly Name] NOT LIKE '%Promo%' 
							OR
							s.[SKu Sub Type] = 'DevTest' and (s.[EA Portal Friendly Name] NOT LIKE '%DevTest%' AND s.[EA Portal Friendly Name] NOT LIKE '%Dev/Test%' ) )
							)
							THEN s.[EA Portal Friendly Name] END
							END,
	[Remarks] = CASE WHEN (
							(s.[SKu Sub Type] = 'Promo' and s.[Material Description] NOT LIKE '%Promo%' 
							OR
							s.[SKu Sub Type] = 'DevTest' and (s.[Material Description] NOT LIKE '%DevTest%' AND s.[Material Description] NOT LIKE '%DvTst%') )
							)
							THEN 'SKU Material Description field does not contain: '+s.[SKu Sub Type]
							ELSE CASE WHEN (
							(s.[SKu Sub Type] = 'Promo' and s.[EA Portal Friendly Name] NOT LIKE '%Promo%' 
							OR
							s.[SKu Sub Type] = 'DevTest' and (s.[EA Portal Friendly Name] NOT LIKE '%DevTest%' AND s.[EA Portal Friendly Name] NOT LIKE '%Dev/Test%' ) )
							)
							THEN 'SKU EA Portal Friendly Name field does not contain: '+s.[SKu Sub Type] END
							END,
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	
FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeter] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKU] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]

		where s.[SKu Sub Type] <> ' '
		AND e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
		and (
		(s.[SKu Sub Type] = 'Promo' and (s.[Material Description] NOT LIKE '%Promo%' OR s.[EA Portal Friendly Name] NOT LIKE '%Promo%' ))
		OR  (s.[SKu Sub Type] = 'DevTest' and (
			(s.[Material Description] NOT LIKE '%DevTest%' AND s.[Material Description] NOT LIKE '%DvTst%') 
			OR 
			(s.[EA Portal Friendly Name] NOT LIKE '%DevTest%' AND s.[EA Portal Friendly Name] NOT LIKE '%Dev/Test%' ) 
			)
			)
		)
		
	RETURN 
END
GO
