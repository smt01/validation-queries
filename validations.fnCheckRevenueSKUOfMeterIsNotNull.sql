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
-- Description:	Checks if the Revenue SKU property of the meter is null
--				m.[Revenue SKU] IS NULL
-- =============================================
CREATE FUNCTION [validations].[fnCheckRevenueSKUOfMeterIsNotNull]
(
	
)
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
	[Validation Name] = 'Revenue SKU of Meter should not be null',	
	[Flagged Column Name] = CASE WHEN ( m.[Revenue SKU] IS NULL) 
							THEN 'Meter Reveue SKU' 
							END,
	[Flagged Column Value] = m.[Revenue SKU],
	[Remarks] = 'The value of Revenue SKU should not be ' + CAST(m.[Revenue SKU] as nvarchar(max)),
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	FROM
		 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeter] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
	WHERE 
		m.[Revenue SKU] IS NULL
		AND e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
	RETURN 
END
GO