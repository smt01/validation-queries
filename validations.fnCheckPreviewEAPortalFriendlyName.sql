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
-- Author:		Tripathi,Shubhang
-- Create date: 7'th June 2019
-- Description:	Checks for the presence of the word 'Preview' in EA Portal Friendly name
--				Returns records where :
--				(s.[EA Portal Friendly Name]  LIKE '%PREVIEW%' AND s.[SAP Sku Sub Type] NOT LIKE '%PREVIEW%')
--			     OR
--				(s.[EA Portal Friendly Name] NOT LIKE '%PREVIEW' AND s.[SAP Sku Sub Type] LIKE '%PREVIEW%')
-- =============================================
CREATE FUNCTION [validations].[fnCheckPreviewEAPortalFriendlyName]
(
	
)
RETURNS @rtnTable TABLE (
	[Test ID] nvarchar(max) NOT NULL,
	[Result ID] INT	NOT NULL,
	[Flagged Column Name] nvarchar(max) NULL,
	[EA Portal Friendly Name] nvarchar(max) not null,
	[Launch Stage] nvarchar(max) NULL,
	[Meter ID] INT NULL,
	[Event ID] INT NULL,
	[SAP Rate Start Date] datetime NULL,
	[Cayman Release] nvarchar(max) NULL,	
	[Meter Status] nvarchar(max) NULL
	
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
INSERT INTO @rtnTable
SELECT 
	[Test ID] = 'If SKU Sub Type is Preview EA Portal Name Needs To Have The Word Preview',
	[Result ID] = CASE WHEN (
								(s.[EA Portal Friendly Name]  LIKE '%PREVIEW%' AND s.[SAP Sku Sub Type] NOT LIKE '%PREVIEW%')
									OR
								(s.[EA Portal Friendly Name] NOT LIKE '%PREVIEW' AND s.[SAP Sku Sub Type] LIKE '%PREVIEW%')
							) THEN -1 ELSE 1 END,
	[Flagged Column Name] = CASE WHEN (s.[EA Portal Friendly Name]  LIKE '%PREVIEW%' AND s.[SAP Sku Sub Type] NOT LIKE '%PREVIEW%') THEN 'EA Portal Friendly Name' ELSE 'SAP Sku Sub Type' END,
	[EA Portal Friendly Name] = s.[EA Portal Friendly Name],
	[Launch Stage] = s.[SAP Sku Sub Type],
	[Meter ID] = m.[MeterID],
	[Event ID] = e.[ID],
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	
FROM 
	[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) JOIN 
	[dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] JOIN
	[dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[ID] 
WHERE
	(s.[EA Portal Friendly Name]  LIKE '%PREVIEW%' AND s.[SAP Sku Sub Type] NOT LIKE '%PREVIEW%') -- Launch Stage instead of SAP Sku Sub Type
	OR
	(s.[EA Portal Friendly Name] NOT LIKE '%PREVIEW' AND s.[SAP Sku Sub Type] LIKE '%PREVIEW%')

RETURN 
END
GO