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
-- Create date: 12 June 2019
-- Description:	Checks if the Discontinue Dates are always one day before the PL End Date
-- =============================================
CREATE FUNCTION [validations].[fnCheckDiscontinueDatesBeforePLDate] 
(
	
)
RETURNS @rtnTable TABLE (
	[Test ID] nvarchar(max) NOT NULL,
	[Result ID] INT	NOT NULL,
	[Flagged Column Name] nvarchar(max) NULL,
	[SAP Discontinue Date] datetime  null,
	[Public Status Date] datetime null,
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
	INSERT INTO @rtnTable
	SELECT 
	[Test ID] = 'Discontinue Dates should be Before PL Dates',
	[Result ID] = 1,
	[Flagged Column Name] = 'SAP Discontinue Date',
	[SAP Discontinue Date] = s.[SAP Discontinue Date],
	[Public Status Date] = s. [Public Status Date],
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

(s.[SAP Discontinue Date]) <> (s.[Public Status Date] - 1 )
and
-- gets the last day of the month for the SAP discontinue date)
Day(s.[SAP Discontinue Date]) <> DAY(EOMONTH(s.[SAP Discontinue Date])) 
ORDER BY s.[Public Status Date] DESC

	RETURN 
END
GO