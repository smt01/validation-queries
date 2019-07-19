USE [dbASOMS_Validation]
GO
/****** Object:  UserDefinedFunction [validations].[fnCheckDiscontinueDatesBeforePLDate]    Script Date: 7/19/2019 3:11:05 PM ******/
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
	[Work Item Type] = 'Consumption SKU',
	[Work Item ID] = s.[ConsumptionSkuID],	
	[Validation Name] = 'SAP Discontinue Date should be Before PL Dates',	
	[Flagged Column Name] = 'SAP Discontinue Date',
	[Flagged Column Value] = CAST(s.[SAP Discontinue Date] AS DATE),
	[Remarks] = 'The SAP Discontinue Date should be one day before the PL date of: '+ CAST(CAST(s. [Public Status Date] as DATE) as nvarchar(max)),
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = CAST(e.[SAP Rate Start Date] as DATE),
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]

FROM 
	[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
	JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
	JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]


WHERE 

	(
	(cast(s.[SAP Discontinue Date] as date)) <>	DATEADD(DAY,-1,cast(s.[SAP Rate Start Date] as date))
)
	--AND Day(s.[SAP Discontinue Date]) <> DAY(EOMONTH(s.[SAP Discontinue Date])) 
	AND e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight

ORDER BY s.[SAP Rate Start Date] DESC

RETURN 
END
