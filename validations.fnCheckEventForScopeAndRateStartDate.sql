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
-- Create date: 3 July 2019
-- Description:	Returns events which have either Scope/Rate Start Date and the other is null
--				User story: https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/528
-- =============================================
CREATE FUNCTION [validations].[fnCheckEventForScopeAndRateStartDate] 
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
[Work Item Type] = 'Event',
	[Work Item ID] = e.[ID],	
	[Validation Name] = 'An event should have either both Cayman Release and Rate Start Date or niether',	
	[Flagged Column Name] = CASE WHEN (e.[Cayman Release] is not NULL AND e.[CP Rate Start Date] is NULL )
							THEN 'CP Rate Start Date' ELSE
							CASE WHEN  (e.[CP Rate Start Date] is not NULL AND e.[Cayman Release] is NULL)
							THEN 'Cayman Release' END
							END,
	[Flagged Column Value] =CASE WHEN (e.[Cayman Release] is not NULL AND e.[CP Rate Start Date] is NULL )
							THEN e.[CP Rate Start Date] ELSE
							CASE WHEN  (e.[CP Rate Start Date] is not NULL AND e.[Cayman Release] is NULL)
							THEN e.[Cayman Release] END
							END,
	[Remarks] =				CASE WHEN (e.[Cayman Release] is not NULL AND e.[CP Rate Start Date] is NULL )
							THEN 'No CP Rate Start Date Assigned' ELSE
							CASE WHEN  (e.[CP Rate Start Date] is not NULL AND e.[Cayman Release] is NULL)
							THEN 'No Cayman Release Assigned' END
							END ,
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeter] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKU] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
	where (e.[Cayman Release] != '') --Adding this to remove 'empty' Cayman Releases
	AND (
			(e.[Cayman Release] is not NULL AND e.[CP Rate Start Date] is NULL )
			OR
			(e.[CP Rate Start Date] is not NULL AND e.[Cayman Release] is NULL)
		)
	RETURN 
END
GO