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
-- Create date: 15 July 2019
-- Description:	'VM' should not be included in cloud service naming field
--				More details here: https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/100
-- =============================================


CREATE FUNCTION [validations].[fnCheckMeterNamingFields]
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
	[Work Item ID] = m.[MeterID],	
	[Validation Name] = 'Cloud Services may not have VM in naming fields',	
	[Flagged Column Name] = CASE WHEN (
                                m.[Service Name] like '%VM%'
							)THEN 'Service Name' ELSE
							CASE WHEN (
							m.[Resorce Name] like '%VM%'
							)
							THEN 'Resource Name' END
							END,
	[Flagged Column Value] = CASE WHEN (
                                m.[Service Name] like '%VM%'
							)THEN m.[Service Name] ELSE
							CASE WHEN (
							m.[Resorce Name] like '%VM%'
							)
							THEN m.[Resorce Name] END
							END,
	[Remarks] = CASE WHEN (
                                m.[Service Name] like '%VM%'
							)THEN 'The Service Name shouldnot contain VM in it' ELSE
							CASE WHEN (
							m.[Resorce Name] like '%VM%'
							)
							THEN 'The Resource Name shouldnot contain VM in it' END
							END,
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	
FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKU] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]

		where
		 e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
		and (m.[Service Type] LIKE '%Cloud Services%')
        AND (
            (m.[Resorce Name] like '%VM%')
            OR
            (m.[Service Name] like '%VM%')
            )
		
	RETURN 
END
GO
