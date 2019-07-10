USE [dbASOMS_Validation]
GO
/****** Object:  UserDefinedFunction [validations].[fnCheckNoChangeUoMAndRatesMeters]    Script Date: 6/24/2019 11:10:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tripathi, Shubhang
-- Create date: 20 June 2019
-- Description:	UoM does not change if Rate does not change (for SKUs)
--				More description can be found here: https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/125
-- =============================================


-- Flip the comparison and check again
CREATE FUNCTION [validations].[fnCheckNoChangeUoMAndRatesSKU]
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
	[Validation Name] = 'EA UoM should not change if EA Rate does not change',	
	[Flagged Column Name] = CASE WHEN ( s.[EA Unit of Measure] <> (SELECT  sh.[EA Unit of Measure]
									  FROM [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] sh
									  where sh.[Resource GUID] = s.[Resource GUID]
									  AND sh.MeterID = s.MeterID
									  and sh.ConsumptionSkuID = s.ConsumptionSkuID )	
							) THEN 'Meter Direct Unit of Measure'
							ELSE CASE WHEN (s.[EA Rate] <> (SELECT  sh.[EA Rate]
									  FROM [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] sh
									  where sh.[Resource GUID] = s.[Resource GUID]
									  AND sh.MeterID = s.MeterID
									  and sh.ConsumptionSkuID = s.ConsumptionSkuID
									  )) THEN 'Meter Direct Rate' END
									  END,
	[Flagged Column Value] = CASE WHEN ( s.[EA Unit of Measure] <> (SELECT  sh.[EA Unit of Measure]
									  FROM [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] sh
									  where sh.[Resource GUID] = s.[Resource GUID]
									  AND sh.MeterID = s.MeterID
									  and sh.ConsumptionSkuID = s.ConsumptionSkuID )	
							) THEN CAST(s.[EA Unit of Measure] as nvarchar(max))
							ELSE CASE WHEN (s.[EA Rate] <> (SELECT  sh.[EA Rate]
									  FROM [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] sh
									  where sh.[Resource GUID] = s.[Resource GUID]
									  AND sh.MeterID = s.MeterID
									  and sh.ConsumptionSkuID = s.ConsumptionSkuID
									  )) THEN CAST(s.[EA Rate] as nvarchar(max)) END
									  END,
	[Remarks] = 'EA UoM should not change if EA Rate does not change',
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status] = m.[Meter Status]

	from  [dbASOMS_Production].[Prod].[vwASOMSEvent] e  				
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeter] m on m.[Parent id] = e.ID
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKU] s on s.[Parent ID] = m.MeterID
where (s.[EA Unit of Measure] <> NULL or s.[EA Rate] <> NULL)
 AND (s.[EA Unit of Measure]<> (SELECT  sh.[EA Unit of Measure]
									  FROM [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] sh
									  where sh.[Resource GUID] = s.[Resource GUID]
									  AND sh.MeterID = s.MeterID
									  and sh.ConsumptionSkuID = s.ConsumptionSkuID
									  )
									  )
	 OR
	( s.[EA Rate] <> (SELECT  sh.[EA Rate]
									  FROM [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] sh
									  where sh.[Resource GUID] = s.[Resource GUID]
									  AND sh.MeterID = s.MeterID
									  and sh.ConsumptionSkuID = s.ConsumptionSkuID
									  )
									  )
AND e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
	RETURN 
END
