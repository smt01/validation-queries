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
-- Create date: 10 June 2019
-- Description:	Checks for Non-GL Linked China (CN) meters which have a Dev/Test instance
--				More description could be found at https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/103
-- =============================================
CREATE FUNCTION [validations].[fnNonGLLinkedCNMetersDevTest]
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
	[Work Item ID] = m.[MeterID],

	[Validation Name] = 'Non-GL Linked China Meters should not have a Dev/Test Instance',	
	[Flagged Column Name] = 'Azure Instance',
	[Flagged Column Value] = s.[Azure Instance],
	[Remarks] = 'Non-GL Linked China Meters Should not have a Dev/Test Instance' ,
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
		
	
FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeter] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
where 
		s.[Azure Instance] = 'China'
and		m.[Region Name] NOT IN ('Zone 1', 'Azure Stack', 'Azure Stack CN', NULL)
and		m.[Has DevTest Sku] = 'No'
and		(m.[DevTest Discount Percentage] IS NOT NULL OR m.[DevTest Discount Rate] IS NOT NULL)
and     e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight

RETURN 
END
GO