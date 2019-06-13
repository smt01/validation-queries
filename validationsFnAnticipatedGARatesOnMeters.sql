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
-- Create date: 6'th June 2019
-- Description:	Validations for the 'Material Desription' Field. See story here: --https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/117
-- =============================================
CREATE FUNCTION [validations].[fnAnticipatedGARatesOnMeters] ()
RETURNS @rtnTable TABLE (
	[Test ID] nvarchar(50) NOT NULL,
	[Result ID] INT	NOT NULL,
	[State] nvarchar NULL,
	[Meter ID] INT NULL,
	[Event ID] INT NULL,
	[SAP Rate Start Date] datetime NULL,
	[Cayman Release] nvarchar(255) NULL,
	[Anticipated GA Rates] float NULL,
	[Flagged Column Name] nvarchar(max) NULL
	
) 

AS
BEGIN
	-- Fill the table variable with the rows for your result set
	INSERT INTO @rtnTable
	SELECT
	[Test ID] = 'Anticipated GA Rates On Meters',
	[RESULT ID] = CASE 
	WHEN (select count(*) 
	FROM [dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeter] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID] 
	where (s.[State]) not in ('New', 'Cancelled', 'On Hold')
	and (m.[Meter Status] not in ('Never used','Never Used', 'NeverUsed')) -- checking out possible variations of the spelling/usage
	and (m.[Anticipated GA Rate] IS NULL OR m.[Anticipated GA Rate] < 0)  ) > 0 THEN 1 ELSE -1 END,
	[Anticipated GA Rate] = m.[Anticipated GA Rate],
	[State] = s.[State],
	[Cayman Release] = e.[Cayman Release],
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Meter ID] = m.[MeterID],
	[Event ID] = e.[ID],
	[Flagged Column Name] = 'Anticipated GA Rate'

	FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeter] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
		
	where 
		(s.[State]) not in ('New', 'Cancelled', 'On Hold')
		and (m.[Meter Status] not in ('Never used','Never Used', 'NeverUsed')) -- checking out possible variations of the spelling/usage
		and (m.[Anticipated GA Rate] IS NULL OR m.[Anticipated GA Rate] < 0) 

	RETURN 


	
END
GO