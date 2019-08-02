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
-- Create date: 2'nd Aug 2019
-- Description:	Returns the list of Resource GUIDs which are not unique for a particular release
--				More Information here: 
-- =============================================
CREATE FUNCTION [validations].[fnCheckDuplicateResourceGUIDInRelease] 
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
		INSERT into @rtnTable
		SELECT
		[Event ID] = e.[ID],
		[Work Item Type] = 'Meter',
	[Work Item ID] = m.MeterID,

	[Validation Name] = 'Resource GUIDs should not be duplicated in a single release',	
	[Flagged Column Name] = 'Resource GUID',
	[Flagged Column Value] = m.[Resource GUID],							 
	[Remarks] = 'SKU in the whitelisted region should always be in permanent lead',
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
		
	

FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
WHERE ISNULL(e.[Cayman Release], '') <> ''
and     e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
GROUP BY e.[Cayman Release],m.[Resource GUID], e.ID, m.MeterID, s.[State], e.[SAP Rate Start Date], m.[Meter Status]
Having COUNT(distinct m.[Resource GUID]) > 1
ORDER BY e.[Cayman Release] DESC



RETURN 
END
GO