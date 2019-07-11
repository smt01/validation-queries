USE [dbASOMS_Validation]
GO
/****** Object:  UserDefinedFunction [validations].[fnCheckMeterForTagChangeOnModify]    Script Date: 7/3/2019 10:46:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tripathi, Shubhang
-- Create date: 1 July 2019
-- Description:	A modified meter should have atleast one change tag marked.
--				User Story: https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/124
-- =============================================
CREATE FUNCTION [validations].[fnCheckMeterForTagChangeOnModify] 
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
[Work Item Type] = 'Meter',
	[Work Item ID] = m.MeterID,	
	[Validation Name] = 'A modified meter should have at least one change tag marked',	
	[Flagged Column Name] = 'Has Meter Status Changed' ,
	[Flagged Column Value] = m.[Has Meter Status Changed],  ---m.[Has Meter Status Changed],
	[Remarks] = 'No tags have been changed for this modified meter. ',
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKU] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
	Where
	e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight 
	AND (e.[Change Type] = 'Modify Existing')
	AND ([dbASOMS_Validation].[validations].[fnCheckMeterForTagChange](e.EventID, m.MeterID) <> 1)

	RETURN 
END
