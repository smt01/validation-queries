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
	[Test ID] nvarchar(max) NOT NULL,
	[Result ID] INT	NOT NULL,
	[Flagged Column Name] nvarchar(max) NULL,
	[Material Description] nvarchar(max) not null,
	[State] nvarchar(max) NULL,
	[Meter ID] INT NULL,
	[Event ID] INT NULL,
	[SAP Rate Start Date] datetime NULL,
	[Cayman Release] nvarchar(max) NULL,	
	[Meter Status] nvarchar(max) NULL
	
)
AS
BEGIN
	-- SELECT LOGIC HERE

	INSERT INTO @rtnTable
	SELECT 
	[Test ID] = 'Material Description Should Begin with AZ ',
	[Result ID] = CASE WHEN (SUBSTRING(s.[Material Description], 1, 3) <>'AZ '   OR (TRIM(s.[Material Description]) = ' ' )) THEN -1 ELSE 1 END,
	[Flagged Column Name] = 'Material Description',
	[Material Description] = s.[Material Description],
	[State] = s.[State],
	[Meter ID] = m.[MeterID],
	[Event ID] = e.[ID],
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]

	FROM [dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[ID] 
	where (s.[State]) not in ('New', 'Cancelled', 'On Hold')
	and 	s.[Material Description] IS NOT NULL 
	and	(SUBSTRING(s.[Material Description], 1, 3) <>'AZ '   OR (TRIM(s.[Material Description]) = ' ' )) 
	RETURN 
END
