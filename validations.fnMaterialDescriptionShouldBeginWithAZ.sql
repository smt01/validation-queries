USE [dbASOMS_Validation]
GO
/****** Object:  UserDefinedFunction [validations].[fnMaterialDescriptionShouldBeginWithAZ]    Script Date: 6/7/2019 11:25:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tripathi,Shubhang
-- Create date: 7'th June 2019
-- Description:	Gets a list of Consumption SKUs whose material description does not begin with 'AZ '
-- =============================================
ALTER FUNCTION [validations].[fnMaterialDescriptionShouldBeginWithAZ]
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
	[Validation Name] = 'SKU Material Description should begin with an "AZ " ',	
	[Flagged Column Name] = CASE WHEN ( 
								 s.[Material Description] IS NULL 
								 OR
								 (SUBSTRING(s.[Material Description], 1, 3) <>'AZ '   OR (TRIM(s.[Material Description]) = ' ' )) ) 
							THEN 'SKU Material Description' 
							END,
	[Flagged Column Value] = s.[Material Description],
	[Remarks] = 'The SKU Material Description should begin with "AZ " instead of  ' + s.[Material Description],
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]

	FROM [dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[ID] 
	where (s.[State]) not in ('New', 'Cancelled', 'On Hold')
	and 	s.[Material Description] IS NOT NULL 
	and	(SUBSTRING(s.[Material Description], 1, 3) <>'AZ '   OR (TRIM(s.[Material Description]) = ' ' ))
	AND e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
	RETURN 
END
