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
	[Event ID] INT NULL,
	[Meter ID] INT NULL,
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
	[Meter ID] = m.[MeterID],
	[Validation Name] = 'Anticipated GA Rates On meters should not be blank',	
	[Flagged Column Name] = CASE WHEN (m.[Anticipated GA Rate] IS NULL OR m.[Anticipated GA Rate] < 0 OR m.[Anticipated GA Rate] = ' ') 
							THEN 'Meter Anticipated GA Rate' 
							END,
	[Flagged Column Value] = m.[Anticipated GA Rate],
	[Remarks] = 'The anticipated GA Rates on meters should not be ' + CAST(m.[Anticipated GA Rate] as nvarchar(max)),
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	

	FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeter] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
		
	where 
		(s.[State]) not in ('New', 'Cancelled', 'On Hold')
		and (m.[Meter Status] not in ('Never used','Never Used', 'NeverUsed')) -- checking out possible variations of the spelling/usage
		and (m.[Anticipated GA Rate] IS NULL OR m.[Anticipated GA Rate] < 0)
		and e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight

	RETURN 


	
END
GO