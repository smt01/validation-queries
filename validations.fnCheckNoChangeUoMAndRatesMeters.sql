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
-- Create date: 20 June 2019
-- Description:	UoM does not change if Rate does not change (for meters)
--				More description can be found here: https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/125
-- =============================================
CREATE FUNCTION [validations].[fnCheckNoChangeUoMAndRatesMeters]
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
	[Validation Name] = 'UoM should not change if Direct Rate does not change',	
	[Flagged Column Name] = CASE WHEN ( m.[Direct Unit of Measure] <> (SELECT TOP(1) mhr.[Direct Unit of Measure]
									  FROM [dbASOMS_Production].[Prod].[vwASOMSMeter] mhr
									  where mhr.[Resource GUID] = m.[Resource GUID]
									  AND mhr.MeterID = m.MeterID)	
							) THEN 'Meter Direct Unit of Measure'
							ELSE CASE WHEN (m.[Direct Rate] <> (SELECT TOP(1) mhr.[Direct Rate]
									  FROM [dbASOMS_Production].[Prod].[vwASOMSMeter] mhr
									  where mhr.[Resource GUID] = m.[Resource GUID]
									  AND mhr.MeterID = m.MeterID									 
									  )) THEN 'Meter Direct Rate' END
									  END,
	[Flagged Column Value] = CASE WHEN ( m.[Direct Unit of Measure] <> (SELECT TOP(1) mhr.[Direct Unit of Measure]
									  FROM [dbASOMS_Production].[Prod].[vwASOMSMeter] mhr
									  where mhr.[Resource GUID] = m.[Resource GUID]
									  AND mhr.MeterID = m.MeterID)	
							) THEN m.[Direct Unit of Measure]
							ELSE CASE WHEN (m.[Direct Rate] <> (SELECT TOP(1) mhr.[Direct Rate]
									  FROM [dbASOMS_Production].[Prod].[vwASOMSMeter] mhr
									  where mhr.[Resource GUID] = m.[Resource GUID]
									  AND mhr.MeterID = m.MeterID									 
									  )) THEN m.[Direct Rate] END
									  END,
	[Remarks] = 'UoM should not change if direct rate doesnt change ',
	[SKU State] = (SELECT s.[State] 
				  from [dbASOMS_Production].[Prod].[vwASOMSMeterHist] mh
				  JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s
				  ON s.[Parent ID] = mh.[ID]
				  where mh.[Parent id] = e.[ID]),	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status] = m.[Meter Status]

	from [dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 				
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeter] m on m.[Parent id] = e.ID
where m.[Resource GUID] <> ' ' 
and (m.[Direct Unit of Measure] <> (SELECT TOP(1) mhr.[Direct Unit of Measure]
									  FROM [dbASOMS_Production].[Prod].[vwASOMSMeter] mhr
									  where mhr.[Resource GUID] = m.[Resource GUID]
									  AND mhr.MeterID = m.MeterID
									 -- ORDER BY mhr.[Changed Date] DESC)
									 )
	 OR
	 m.[Direct Rate] <> (SELECT TOP(1) mhr.[Direct Rate]
									  FROM [dbASOMS_Production].[Prod].[vwASOMSMeter] mhr
									  where mhr.[Resource GUID] = m.[Resource GUID]
									  AND mhr.MeterID = m.MeterID
									  --ORDER BY mhr.[Changed Date] DESC)
									  ))
AND e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
	RETURN 
END
GO