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
	[Test ID] nvarchar(max) NOT NULL,
	[Result ID] INT	NOT NULL,
	[Flagged Column Name] nvarchar(max) NULL,
	[DevTest Discount Percentage] nvarchar(max) null,
	[DevTest Discount Rate] nvarchar(max) null,
	[Azure Instance] nvarchar(max),
	[Region Name] nvarchar(max),
	[Has DevTest Sku] nvarchar(20) null,
	[State] nvarchar(max) NULL,
	[Meter ID] INT NULL,
	[Event ID] INT NULL,
	[SAP Rate Start Date] datetime NULL,
	[Cayman Release] nvarchar(max) NULL,	
	[Meter Status] nvarchar(max) NULL
	
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
		INSERT into @rtnTable
		SELECT
		[Test ID] = 'Non-GL Linked China Meters should not have a Dev/Test Instance',
		[Result ID] = 1,
		[Flagged Column Name] = CASE WHEN (m.[DevTest Discount Percentage] IS NOT NULL) THEN 'DevTest Discount Percentage' ELSE  'DevTest Discount Rate' END,
		[DevTest Discount Percentage] = m.[DevTest Discount Percentage],
		[DevTest Discount Rate] =m.[DevTest Discount Rate],
		[Azure Instance] = s.[Azure Instance],
		[Region Name] = m.[Region Name],
		[Has DevTest Sku] = m.[Has DevTest Sku],
		[State] = s.[State],
		[Meter ID] = m.[MeterID],
		[Event ID] = e.[ID],
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

RETURN 
END
GO