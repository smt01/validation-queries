USE [dbASOMS_Validation]
GO
/****** Object:  UserDefinedFunction [validations].[fnCheckRegionsOfSKU]    Script Date: 7/17/2019 3:44:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tripathi, Shubhang
-- Create date: 31 July 2019
-- Description:	Returns a list of events whose 'state' is not either Approved or In Progress after CR approver deadline
--				User story: https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/92
-- =============================================
CREATE FUNCTION [validations].[fnCheckPostDeadlineEventState]
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
[Work Item Type] ='Event',
	[Work Item ID] = cast(e.[ID] as nvarchar(max)),	
	[Validation Name] = 'Event State Must be "Approved" or "In Progress" after CR Approver Deadline of: '+ cast(e.[Approval Date] as nvarchar(max))	,	
	[Flagged Column Name] = 'Event State',
	[Flagged Column Value] = e.[State],
	[Remarks] = 'Unexpected event state',
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
WHERE 
	(GETDATE() > e.[Approval Date]) AND 
	e.[State]  not in ( 'Approved', 'In Progress', 'Launch Complete', 'Cancelled') -- do we exclude On Hold as well?


RETURN 
END

